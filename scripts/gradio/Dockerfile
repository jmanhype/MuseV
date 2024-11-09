FROM batmanosama/musev:latest


SHELL ["/bin/bash", "--login", "-c"]

# Check if the user already exists, if not, create it
RUN id -u user || useradd -m -u 1000 user

# Switch to the "user" user
USER user

# Set home to the user's home directory
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Set the working directory to the user's home directory
WORKDIR $HOME/app

RUN echo "docker start" \ 
  && whoami \ 
  && which python \ 
  && pwd

# Copy local files from the specified path into the Docker image
COPY /home/batmanosama/MuseV/ /home/user/app/MuseV/  
RUN chmod -R 777 /home/user/app/MuseV

# Download model checkpoints - Modified to handle existing directories
RUN mkdir -p /home/user/app/MuseV/checkpoints && \
    cd /home/user/app/MuseV/checkpoints && \
    if [ ! -d "models" ]; then \
        git clone https://huggingface.co/TMElyralab/MuseV models && \
        cp -r models/* ./ && \
        rm -rf models; \
    fi

# Set environment variables
RUN echo "export PYTHONPATH=\${PYTHONPATH}:/home/user/app/MuseV:/home/user/app/MuseV/MMCM:/home/user/app/MuseV/diffusers/src:/home/user/app/MuseV/controlnet_aux/src" >> ~/.bashrc

WORKDIR /home/user/app/MuseV/scripts/gradio/

# Add entrypoint script
COPY --chown=user entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
RUN ls -l  ./

EXPOSE 7860

CMD ["./entrypoint.sh"]
