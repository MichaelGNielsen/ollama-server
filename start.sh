#!/bin/bash

# Kør dit hardware-tjek
./nvidia_check.sh
GPU_STATUS=$?

# Sørg for, at mcp-network eksisterer
docker network inspect mcp-network >/dev/null 2>&1 || docker network create mcp-network

if [ $GPU_STATUS -eq 0 ]; then
    echo "Starter Ollama med GPU-acceleration..."
    # Her bruger vi en compose-fil med NVIDIA-support
    docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
    nvidia-smi
else
    echo "Starter Ollama i CPU-mode..."
    # Her starter vi kun standard-tjenesten uden GPU-krav
    docker compose up -d
fi
