#!/usr/bin/env bash
set -euo pipefail

# Start ttyd (web terminal)
ttyd -p 7681 bash &

# Start JupyterLab (token-based by default)
jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser &

# Persist data on /workspace
mkdir -p /workspace/models /workspace/input /workspace/output /workspace/custom_nodes /workspace/user

# Move existing data to /workspace on first run (if volume empty)
if [ -d /opt/ComfyUI/models ] && [ -z "$(ls -A /workspace/models 2>/dev/null)" ]; then
  cp -a /opt/ComfyUI/models/. /workspace/models/ || true
fi
if [ -d /opt/ComfyUI/input ] && [ -z "$(ls -A /workspace/input 2>/dev/null)" ]; then
  cp -a /opt/ComfyUI/input/. /workspace/input/ || true
fi
if [ -d /opt/ComfyUI/output ] && [ -z "$(ls -A /workspace/output 2>/dev/null)" ]; then
  cp -a /opt/ComfyUI/output/. /workspace/output/ || true
fi
if [ -d /opt/ComfyUI/custom_nodes ] && [ -z "$(ls -A /workspace/custom_nodes 2>/dev/null)" ]; then
  cp -a /opt/ComfyUI/custom_nodes/. /workspace/custom_nodes/ || true
fi
if [ -d /opt/ComfyUI/user ] && [ -z "$(ls -A /workspace/user 2>/dev/null)" ]; then
  cp -a /opt/ComfyUI/user/. /workspace/user/ || true
fi

# Symlink to persistent storage
ln -sfn /workspace/models /opt/ComfyUI/models
ln -sfn /workspace/input /opt/ComfyUI/input
ln -sfn /workspace/output /opt/ComfyUI/output
ln -sfn /workspace/custom_nodes /opt/ComfyUI/custom_nodes
ln -sfn /workspace/user /opt/ComfyUI/user

# Start ComfyUI
exec python3 /opt/ComfyUI/main.py --listen 0.0.0.0 --port 8188
