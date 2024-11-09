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

# Clone MuseV repository from the fork
WORKDIR /
RUN git clone https://github.com/jmanhype/MuseV.git /MuseV
WORKDIR /MuseV
RUN git submodule init && \
    git submodule update --init --recursive

# Install MMCV using pip instead of git clone
RUN pip install --no-cache-dir -U openmim && \
    mim install mmengine && \
    mim install "mmcv>=2.0.1" && \
    mim install "mmdet>=3.1.0" && \
    mim install "mmpose>=1.1.0"

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Return to MuseV directory
WORKDIR /MuseV

# Download models from Hugging Face
RUN python -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='TMElyralab/MuseV', local_dir='checkpoints', max_workers=8)"

# Expose Gradio port
EXPOSE 7860

# Set default command to run Gradio interface
CMD ["python", "scripts/gradio/app_docker_space.py"]
