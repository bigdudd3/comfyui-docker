#!/usr/bin/env bash
set -euo pipefail

ROOT=/opt/ComfyUI/custom_nodes
if [ ! -d "$ROOT" ]; then
  exit 0
fi

# Install all requirements.txt files found under custom_nodes
find "$ROOT" -name requirements.txt -print0 | while IFS= read -r -d '' req; do
  echo "Installing $req"
  pip3 install -r "$req"
done
