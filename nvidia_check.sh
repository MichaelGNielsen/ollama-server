#!/bin/bash

# Farvekoder til terminal-output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "--- NVIDIA Hardware Check ---"

# 1. Tjek om nvidia-smi overhovedet findes i PATH
if ! command -v nvidia-smi &> /dev/null; then
    echo -e "${RED}FEJL: nvidia-smi blev ikke fundet.${NC}"
    echo "Sørg for at NVIDIA-drivere er installeret."
    exit 1
fi

# 2. Forsøg at trække data ud fra chippen
# Vi beder om navnet på GPU'en. Hvis kommandoen fejler, er chippen ikke tilgængelig.
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$GPU_NAME" ]; then
    echo -e "${RED}FEJL: nvidia-smi findes, men kunne ikke kommunikere med en GPU.${NC}"
    echo "Dette skyldes ofte en defekt driver eller manglende hardware."
    exit 1
else
    echo -e "${GREEN}SUCCESS: NVIDIA Chip fundet!${NC}"
    echo -e "Model: ${YELLOW}$GPU_NAME${NC}"
    
    # Valgfrit: Vis hukommelsesforbrug
    VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader)
    echo -e "Total VRAM: ${YELLOW}$VRAM${NC}"
    
    exit 0
fi
