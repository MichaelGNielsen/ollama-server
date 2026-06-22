#!/bin/bash
set -e

# Farvekoder
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Ollama Server Starter ==="

# Sørg for, at mcp-network eksisterer
#docker network inspect mcp-network >/dev/null 2>&1 || {
#    echo -e "${YELLOW}Opretter mcp-network...${NC}"
#    docker network create mcp-network
#}

if ! docker network inspect mcp-network >/dev/null 2>&1; then
    echo -e "${YELLOW}Opretter mcp-network...${NC}"
    docker network create mcp-network
fi

# Tjek om .env findes, ellers kopiér fra .env.example
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Advarsel: Ingen .env fundet. Kopierer .env.example → .env${NC}"
    echo "Redigér .env og tilpas din platform, eller genkør med dit eget .env"
    cp .env.example .env
fi

# Tjek for NVIDIA GPU
GPU_AVAILABLE=0
if command -v nvidia-smi &> /dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null)
    if [ -n "$GPU_NAME" ]; then
        GPU_AVAILABLE=1
        echo -e "${GREEN}NVIDIA GPU fundet: $GPU_NAME${NC}"
    fi
fi

if [ $GPU_AVAILABLE -eq 1 ]; then
    echo -e "${GREEN}Starter Ollama med GPU-acceleration...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
    nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu --format=csv,noheader 2>/dev/null | head -1
else
    echo -e "${YELLOW}Ingen NVIDIA GPU fundet — starter i CPU-mode.${NC}"
    echo "Hvis du har et Hailo10 eller andet accelerator,"
    echo "skal det konfigureres manuelt (se README)."
    docker compose up -d
fi

echo -e "${GREEN}Done.${NC}"
echo "Logs: docker compose logs -f"
echo "Stop: ./stop.sh"

docker exec -it ollama ollama ps
