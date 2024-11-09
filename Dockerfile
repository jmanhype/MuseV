FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-devel

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONPATH=/MuseV:/MuseV/MMCM:/MuseV/diffusers/src:/MuseV/controlnet_aux/src

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    libgl1-mesa-glx \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Create and activate conda environment
RUN conda create -n musev python=3.9 -y
SHELL ["conda", "run", "-n", "musev", "/bin/bash", "-c"]

# Clone MuseV repository
RUN git clone https://github.com/TMElyralab/MuseV.git /MuseV
WORKDIR /MuseV
RUN git submodule init && \
    git submodule update --init --recursive

# Clone MMCV using git protocol
WORKDIR /
RUN git config --global http.sslVerify false && \
    git clone --depth 1 https://github.com/open-mmlab/mmcv.git /mmcv || \
    (sleep 5 && git clone --depth 1 https://github.com/open-mmlab/mmcv.git /mmcv)

# Install Python dependencies
WORKDIR /MuseV
RUN pip install --no-cache-dir \
    diffusers>=0.7.2 \
    controlnet_aux>=0.3.0 \
    gradio==4.12 \
    cuid \
    spaces \
    accelerate \
    transformers \
    safetensors

# Install MMCV from source
WORKDIR /mmcv
RUN pip install -e .

# Return to MuseV directory
WORKDIR /MuseV

# Download models from Hugging Face
RUN python -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='TMElyralab/MuseV', local_dir='checkpoints', max_workers=8)"

# Expose Gradio port
EXPOSE 7860

# Set default command to run Gradio interface
CMD ["python", "scripts/gradio/app_docker_space.py"]
