#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Starting entrypoint.sh"
whoami
which python

# Export PYTHONPATH
export PYTHONPATH=${PYTHONPATH}:/home/user/app/MuseV:/home/user/app/MuseV/MMCM:/home/user/app/MuseV/diffusers/src:/home/user/app/MuseV/controlnet_aux/src
echo "PYTHONPATH: $PYTHONPATH"

# Activate the conda environment
source /opt/conda/etc/profile.d/conda.sh
conda activate musev

which python

# Navigate to Gradio scripts directory
cd /home/user/app/MuseV/scripts/gradio/

# Run the Gradio application
exec python app_gradio_space.py
