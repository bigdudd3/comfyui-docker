FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    COMFYUI_MANAGER_SECURITY=weak \
    COMFYUI_MANAGER_SECURITY_FORCE=0 \
    ENABLE_JUPYTER=0 \
    ENABLE_TTYD=0 \
    COMFYUI_ARGS=""

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv python3-dev git wget ca-certificates build-essential \
    libgl1 libglib2.0-0 \
    ttyd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
ARG COMFYUI_REF=master
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /opt/ComfyUI-src \
    && cd /opt/ComfyUI-src \
    && git checkout "$COMFYUI_REF"
WORKDIR /opt/ComfyUI-src

# Install PyTorch + requirements (CUDA 12.1)
RUN pip3 install --upgrade pip \
    && pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip3 install -r requirements.txt \
    && pip3 install jupyterlab \
    && pip3 install --upgrade "sqlalchemy>=2.0"

COPY install_custom_requirements.sh /opt/ComfyUI-src/install_custom_requirements.sh
COPY start.sh /opt/ComfyUI-src/start.sh
RUN chmod +x /opt/ComfyUI-src/start.sh

RUN pip3 uninstall -y torchao || true

# Avoid creating /opt/ComfyUI in the image; we use /opt/ComfyUI-src + symlink at runtime

# Default volume for persisted data
VOLUME ["/workspace"]

EXPOSE 8188 8888 7681

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD wget -qO- http://127.0.0.1:8188/ || exit 1

CMD ["/opt/ComfyUI-src/start.sh"]
