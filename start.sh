#!/usr/bin/env bash
set -euo pipefail

# Persist data on /workspace
mkdir -p /workspace/models /workspace/input /workspace/output /workspace/custom_nodes /workspace/user

# Symlink to persistent storage (replace dirs with symlinks)
for d in models input output user; do
  rm -rf "/opt/ComfyUI/$d"
  ln -sfn "/workspace/$d" "/opt/ComfyUI/$d"
done

# Handle custom_nodes carefully (avoid nested /opt/ComfyUI/custom_nodes/custom_nodes)
if [ ! -L /opt/ComfyUI/custom_nodes ]; then
  if [ -z "$(ls -A /workspace/custom_nodes 2>/dev/null)" ]; then
    cp -a /opt/ComfyUI/custom_nodes/. /workspace/custom_nodes/ || true
  fi
  rm -rf /opt/ComfyUI/custom_nodes
  ln -sfn /workspace/custom_nodes /opt/ComfyUI/custom_nodes
fi

# Optional: auto-update ComfyUI
if [ "${COMFYUI_AUTO_UPDATE:-0}" = "1" ]; then
  git -C /opt/ComfyUI pull --rebase || true
fi

# Ensure ComfyUI-Manager exists in persisted custom_nodes
if [ ! -d /opt/ComfyUI/custom_nodes/ComfyUI-Manager ]; then
  git clone https://github.com/ltdrdata/ComfyUI-Manager /opt/ComfyUI/custom_nodes/ComfyUI-Manager || true
fi

# Optional: auto-update custom nodes (git repos only)
if [ "${CUSTOM_NODES_AUTO_UPDATE:-0}" = "1" ]; then
  for d in /opt/ComfyUI/custom_nodes/*; do
    [ -d "$d/.git" ] || continue
    git -C "$d" pull --rebase || true
  done
fi

# Configure ComfyUI-Manager security (default: weak)
MANAGER_CFG_DIR=/opt/ComfyUI/user/default/ComfyUI-Manager
MANAGER_CFG=$MANAGER_CFG_DIR/config.ini
mkdir -p "$MANAGER_CFG_DIR"
if [ "${COMFYUI_MANAGER_SECURITY_FORCE:-0}" = "1" ] || [ ! -f "$MANAGER_CFG" ]; then
  printf "[default]\nsecurity_level = %s\n" "${COMFYUI_MANAGER_SECURITY:-weak}" | tee "$MANAGER_CFG" >/dev/null
fi

# Install custom node requirements once per volume
if [ -d /opt/ComfyUI/custom_nodes ]; then
  if [ "${FORCE_CUSTOM_REQUIREMENTS:-0}" = "1" ] || [ ! -f /workspace/.custom_requirements_installed ]; then
    /opt/ComfyUI/install_custom_requirements.sh || true
    touch /workspace/.custom_requirements_installed
  fi
fi

# Start ttyd (web terminal) if enabled
if [ "${ENABLE_TTYD:-0}" = "1" ]; then
  ttyd -p 7681 bash &
fi

# Start JupyterLab if enabled
if [ "${ENABLE_JUPYTER:-0}" = "1" ]; then
  jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser &
fi

# Start ComfyUI
exec python3 /opt/ComfyUI/main.py --listen 0.0.0.0 --port 8188 ${COMFYUI_ARGS}
