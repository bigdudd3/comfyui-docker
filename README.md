# ComfyUI Docker (Runpod-friendly)

Build locally (includes your local custom nodes from /Users/olivert/Documents/ComfyUI/custom_nodes):
```bash
docker build -t yourname/comfyui:latest .
```

Run locally (mount your models over network or local):
```bash
docker run --gpus all -p 8188:8188 \
  -v /path/to/models:/opt/ComfyUI/models \
  -v /path/to/output:/opt/ComfyUI/output \
  -v /path/to/input:/opt/ComfyUI/input \
  yourname/comfyui:latest
```

Push to registry:
```bash
docker tag yourname/comfyui:latest <registry>/<user>/comfyui:latest
docker push <registry>/<user>/comfyui:latest
```

Runpod:
- Set the container image to your pushed image.
- Expose port **8188**.
- Mount your network drive to `/opt/ComfyUI/models` (and optionally `/opt/ComfyUI/output`).
