\
    #!/usr/bin/env bash
    set -euo pipefail

    # Batch MP4 → TRUE-ALPHA WebM (VP9) with solid background keying.
    # Fully automated. No prompts. Config via env vars.

    HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    IN_DIR="$HERE/input"
    OUT_DIR="$HERE/output"
    MANIFEST="$OUT_DIR/manifest.json"

    # Config (env overrides)
    BG="${BG:-white}"
    SIM="${SIM:-0.10}"
    BLEND="${BLEND:-0.20}"
    CRF="${CRF:-28}"
    SCALE="${SCALE:-0}"   # 0 = keep
    FPS="${FPS:-0}"       # 0 = keep

    die() { echo "ERROR: $*" >&2; exit 2; }

    mkdir -p "$IN_DIR" "$OUT_DIR"

    # Ensure ffmpeg
    if ! command -v ffmpeg >/dev/null 2>&1; then
      echo "ffmpeg missing; running ensure_ffmpeg.sh..."
      bash "$HERE/ensure_ffmpeg.sh"
    fi

    bg_to_hex() {
      local v="$1"
      case "${v,,}" in
        white) echo "0xFFFFFF" ;;
        green) echo "0x00FF00" ;;
        black) echo "0x000000" ;;
        \#??????) echo "0x${v:1}" ;;
        0x??????) echo "$v" ;;
        *) die "Invalid BG. Use white|green|black|#RRGGBB" ;;
      esac
    }

    HEX_BG="$(bg_to_hex "$BG")"

    # Find MP4s
    mapfile -d '' FILES < <(find "$IN_DIR" -type f \( -iname "*.mp4" \) -print0)

    if [[ ${#FILES[@]} -eq 0 ]]; then
      echo "No .mp4 files found under: $IN_DIR"
      echo "Put videos into input/ and re-run."
      exit 0
    fi

    echo "Found ${#FILES[@]} mp4 file(s)."
    echo "BG=$BG ($HEX_BG) SIM=$SIM BLEND=$BLEND CRF=$CRF SCALE=$SCALE FPS=$FPS"
    echo ""

    # Start manifest
    echo "[" > "$MANIFEST"
    first=1

    for IN in "${FILES[@]}"; do
      # Relative path inside input/
      REL="${IN#$IN_DIR/}"
      REL_NOEXT="${REL%.*}"
      OUT_PATH="$OUT_DIR/${REL_NOEXT}.alpha.webm"
      OUT_DIRNAME="$(dirname "$OUT_PATH")"
      mkdir -p "$OUT_DIRNAME"

      # Build filtergraph: optional fps -> optional scale -> chromakey -> alpha format
      VF=""
      if [[ "$FPS" != "0" ]]; then
        VF="fps=${FPS}"
      fi
      if [[ "$SCALE" != "0" ]]; then
        [[ -n "$VF" ]] && VF+=","
        VF+="scale='if(gt(iw,ih),${SCALE},-1)':'if(gt(iw,ih),-1,${SCALE})':flags=lanczos"
      fi
      [[ -n "$VF" ]] && VF+=","
      VF+="chromakey=${HEX_BG}:${SIM}:${BLEND},format=yuva420p"

      echo "→ $REL"
      ffmpeg -y -i "$IN" \
        -vf "$VF" \
        -an \
        -c:v libvpx-vp9 \
        -pix_fmt yuva420p \
        -auto-alt-ref 0 \
        -b:v 0 -crf "$CRF" \
        -row-mt 1 \
        -deadline good \
        -cpu-used 2 \
        "$OUT_PATH" >/dev/null 2>&1

      # Append manifest entry (minimal JSON escaping)
      IN_ESC="${REL//\\/\\\\}"
      IN_ESC="${IN_ESC//\"/\\\"}"
      OUT_ESC="${OUT_PATH#$OUT_DIR/}"
      OUT_ESC="${OUT_ESC//\\/\\\\}"
      OUT_ESC="${OUT_ESC//\"/\\\"}"

      if [[ $first -eq 0 ]]; then
        echo "," >> "$MANIFEST"
      fi
      first=0
      printf '  {"input":"%s","output":"%s"}' "$IN_ESC" "$OUT_ESC" >> "$MANIFEST"
      echo "" >> "$MANIFEST"
    done

    echo "]" >> "$MANIFEST"
    echo ""
    echo "Done."
    echo "Outputs: $OUT_DIR"
    echo "Manifest: $MANIFEST"
