FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv python3-dev git wget ca-certificates build-essential \
    libgl1 libglib2.0-0 \
    ttyd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /opt/ComfyUI

# Install PyTorch + requirements (CUDA 12.1)
RUN pip3 install --upgrade pip \
    && pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip3 install -r requirements.txt \
    && pip3 install jupyterlab

COPY install_custom_requirements.sh /opt/ComfyUI/install_custom_requirements.sh
COPY start.sh /opt/ComfyUI/start.sh
RUN chmod +x /opt/ComfyUI/start.sh

# Install ComfyUI-Manager properly
RUN rm -rf /opt/ComfyUI/custom_nodes/ComfyUI-Manager \
    && git clone https://github.com/ltdrdata/ComfyUI-Manager /opt/ComfyUI/custom_nodes/ComfyUI-Manager

# Set ComfyUI-Manager security level to weak
RUN mkdir -p /opt/ComfyUI/user/default/ComfyUI-Manager \
    && printf "[default]\nsecurity_level = weak\n" | tee /opt/ComfyUI/custom_nodes/ComfyUI-Manager/config.ini /opt/ComfyUI/user/default/ComfyUI-Manager/config.ini

RUN pip3 uninstall -y torchao || true

# Default volumes for models and outputs
VOLUME ["/opt/ComfyUI/models", "/opt/ComfyUI/output", "/opt/ComfyUI/input", "/opt/ComfyUI/custom_nodes"]

EXPOSE 8188 8888 7681

CMD ["/opt/ComfyUI/start.sh"]
