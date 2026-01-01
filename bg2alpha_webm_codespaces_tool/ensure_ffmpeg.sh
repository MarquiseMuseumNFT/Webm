#!/usr/bin/env bash
set -euo pipefail

if command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg OK: $(ffmpeg -version | head -n 1)"
  exit 0
fi

echo "ffmpeg not found. Installing (Ubuntu/Codespaces)..."
sudo apt-get update
sudo apt-get install -y ffmpeg
echo "ffmpeg installed: $(ffmpeg -version | head -n 1)"
