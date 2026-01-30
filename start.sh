#!/usr/bin/env bash
set -euo pipefail

# Start ttyd (web terminal)
ttyd -p 7681 bash &

# Start JupyterLab (token-based by default)
jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser &

# Persist data on /workspace
mkdir -p /workspace/models /workspace/input /workspace/output /workspace/custom_nodes /workspace/user

# Symlink to persistent storage
ln -sfn /workspace/models /opt/ComfyUI/models
ln -sfn /workspace/input /opt/ComfyUI/input
ln -sfn /workspace/output /opt/ComfyUI/output
ln -sfn /workspace/custom_nodes /opt/ComfyUI/custom_nodes
ln -sfn /workspace/user /opt/ComfyUI/user

# Install custom node requirements once per volume
if [ -d /opt/ComfyUI/custom_nodes ] && [ ! -f /workspace/.custom_requirements_installed ]; then
  /opt/ComfyUI/install_custom_requirements.sh || true
  touch /workspace/.custom_requirements_installed
fi

# Start ComfyUI
exec python3 /opt/ComfyUI/main.py --listen 0.0.0.0 --port 8188
