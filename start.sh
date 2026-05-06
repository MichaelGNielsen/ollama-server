#!/bin/bash

# Kør dit hardware-tjek
./check_gpu.sh
GPU_STATUS=$?

if [ $GPU_STATUS -eq 0 ]; then
    echo "Starter Ollama med GPU-acceleration..."
    # Her bruger vi en compose-fil med NVIDIA-support
    docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
else
    echo "Starter Ollama i CPU-mode..."
    # Her starter vi kun standard-tjenesten uden GPU-krav
    docker compose up -d
fi
