#!/usr/bin/env bash
set -euo pipefail

# Start ttyd (web terminal)
ttyd -p 7681 bash &

# Start JupyterLab (token-based by default)
jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser &

# Install custom node requirements (if present)
if [ -d /opt/ComfyUI/custom_nodes ]; then
  /opt/ComfyUI/install_custom_requirements.sh || true
fi

# Start ComfyUI
exec python3 /opt/ComfyUI/main.py --listen 0.0.0.0 --port 8188
