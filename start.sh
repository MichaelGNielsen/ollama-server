#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Ollama Server Starter ==="

# Sørg for at mcp-network eksisterer
if ! docker network inspect mcp-network >/dev/null 2>&1; then
    echo -e "${YELLOW}Opretter mcp-network...${NC}"
    docker network create mcp-network
fi

# ----- Auto-detektion af hardware -----
GPU_AVAILABLE=0
GPU_NAME=""
VRAM_MIB=0
TOTAL_RAM_GB=$(free -g | awk '/^Mem:/ {print $2}')
FREE_RAM_GB=$(free -g | awk '/^Mem:/ {print $4}')

if command -v nvidia-smi &> /dev/null; then
    # Retry-loop: NVIDIA driver er måske ikke loaded endnu (boot race condition)
    for i in $(seq 1 12); do
        GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || true)
        if [ -n "$GPU_NAME" ]; then
            GPU_AVAILABLE=1
            VRAM_MIB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null || echo "0")
            echo -e "${GREEN}GPU fundet: $GPU_NAME${NC}"
            break
        fi
        echo -e "${YELLOW}Venter på NVIDIA driver... (${i}/12)${NC}"
        sleep 5
    done
fi

# ----- Sæt optimale værdier baseret på hardware -----
if [ $GPU_AVAILABLE -eq 1 ]; then
    # Tjek om det er Blackwell unified memory (GB10/GX10)
    if echo "$GPU_NAME" | grep -qiE "GB10|GX10|Blackwell" || [ "$VRAM_MIB" = "0" ] || [ "$VRAM_MIB" = "[N/A]" ]; then
        echo -e "${GREEN}Blackwell (GB10/GX10) unified memory — ${TOTAL_RAM_GB} GB RAM total${NC}"
        export OLLAMA_NUM_CTX=262144
        export OLLAMA_NUM_PARALLEL=4
        export OLLAMA_KEEP_ALIVE=24h
        export CUDA_FORWARD_COMPAT_DISABLE=0
        export OLLAMA_OVERRIDE_VRAM_SIZE=64424509440
    else
        # Almindeligt NVIDIA GPU med dedikeret VRAM
        echo -e "${GREEN}NVIDIA GPU med ${VRAM_MIB} MiB VRAM${NC}"
        export OLLAMA_KEEP_ALIVE=24h

        if [ "$VRAM_MIB" -ge 24576 ]; then
            export OLLAMA_NUM_CTX=32768
            export OLLAMA_NUM_PARALLEL=4
        elif [ "$VRAM_MIB" -ge 12288 ]; then
            export OLLAMA_NUM_CTX=16384
            export OLLAMA_NUM_PARALLEL=2
        elif [ "$VRAM_MIB" -ge 6144 ]; then
            export OLLAMA_NUM_CTX=8192
            export OLLAMA_NUM_PARALLEL=1
        else
            export OLLAMA_NUM_CTX=4096
            export OLLAMA_NUM_PARALLEL=1
        fi
    fi

    echo -e "${GREEN}Starter Ollama med GPU-acceleration...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
    nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu --format=csv,noheader 2>/dev/null | head -1
else
    # CPU-mode — brug system RAM som rettesnor
    echo -e "${YELLOW}Ingen NVIDIA GPU fundet — starter i CPU-mode${NC}"
    export OLLAMA_KEEP_ALIVE=24h

    if [ "$TOTAL_RAM_GB" -ge 32 ]; then
        export OLLAMA_NUM_CTX=16384
        export OLLAMA_NUM_PARALLEL=2
    elif [ "$TOTAL_RAM_GB" -ge 16 ]; then
        export OLLAMA_NUM_CTX=8192
        export OLLAMA_NUM_PARALLEL=1
    else
        export OLLAMA_NUM_CTX=4096
        export OLLAMA_NUM_PARALLEL=1
    fi

    echo -e "${YELLOW}CPU-mode med ${TOTAL_RAM_GB} GB RAM — NUM_CTX=$OLLAMA_NUM_CTX${NC}"
    docker compose up -d
fi

echo -e "${GREEN}Done.${NC}"
echo "Logs: docker compose logs -f"
echo "Stop: ./stop.sh"

docker exec -it ollama ollama ps 2>/dev/null || true
