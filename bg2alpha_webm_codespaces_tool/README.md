# Codespaces: MP4 → TRUE-ALPHA WebM (VP9) — automated batch tool

**No prompts. Fully automated.**  
Put MP4s in `input/`, run `./run.sh`, get alpha WebMs in `output/` plus `output/manifest.json`.

## Folder layout
```
bg2alpha_webm_codespaces_tool/
  input/              <-- put MP4(s) here (can be nested)
  output/             <-- generated .webm files
  run.sh              <-- main entrypoint (batch)
  ensure_ffmpeg.sh    <-- installs ffmpeg if missing (Ubuntu)
  README.md
```

## Run (Codespaces)
```bash
chmod +x run.sh ensure_ffmpeg.sh
./run.sh
```

## Configuration (env vars, optional)
- BG: `white` (default) | `green` | `black` | `#RRGGBB`
- SIM: similarity (default `0.10`) typical 0.05–0.20
- BLEND: edge softness (default `0.20`) typical 0.10–0.35
- CRF: VP9 quality (default `28`) lower = better/bigger
- SCALE: max dimension (default `0`=keep) e.g. `1024`
- FPS: force fps (default `0`=keep) e.g. `30`

Example:
```bash
BG=white SIM=0.12 BLEND=0.25 CRF=28 SCALE=1024 FPS=30 ./run.sh
```

## Notes
- Best results require a **flat solid background** (no gradient/vignette/shadows).
- This tool only keys background + encodes alpha WebM; it does not create loops.
