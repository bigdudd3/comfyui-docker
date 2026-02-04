# ComfyUI Docker (Runpod-friendly)

Build locally:
```bash
docker build -t yourname/comfyui:latest .
```

Run locally (persist everything under /workspace):
```bash
docker run --gpus all -p 8188:8188 \
  -v /path/to/data:/workspace \
  yourname/comfyui:latest
```

Data layout inside the volume:
- `/workspace/models`
- `/workspace/input`
- `/workspace/output`
- `/workspace/custom_nodes`
- `/workspace/user`

Push to registry:
```bash
docker tag yourname/comfyui:latest <registry>/<user>/comfyui:latest
docker push <registry>/<user>/comfyui:latest
```

Runpod:
- Set the container image to your pushed image.
- Expose port **8188**.
- Mount your network drive to **/workspace**.
- No custom command/entrypoint needed (the image handles persistence automatically).

## Optional environment variables
- `ENABLE_JUPYTER=1` → start JupyterLab on port 8888 (root: /workspace, base_url: /lab)
- `JUPYTER_ROOT=/workspace` → override Jupyter root directory
- `ENABLE_TTYD=1` → start ttyd web terminal on port 7681
- `COMFYUI_ARGS="--preview-method auto"` → extra CLI args
- `COMFYUI_AUTO_UPDATE=1` → git pull ComfyUI on start
- `CUSTOM_NODES_AUTO_UPDATE=1` → git pull any custom_nodes repos on start
- `COMFYUI_MANAGER_SECURITY=weak|normal|strict` (default: weak)
- `COMFYUI_MANAGER_SECURITY_FORCE=1` → overwrite existing config on start
- `FORCE_CUSTOM_REQUIREMENTS=1` → re-install custom node requirements
