#!/bin/bash

# Farver til output
RED='\033[0;31m'
NC='\033[0m'

echo "--- Stopper Ollama og rydder op ---"

# Vi bruger begge filer for at sikre, at Docker genkender hele projekt-strukturen.
# --remove-orphans sikrer, at containere der ikke længere er i yaml-filerne også fjernes.
docker compose -f docker-compose.yml -f docker-compose.gpu.yml down --remove-orphans

if [ $? -eq 0 ]; then
    echo -e "${RED}Ollama er nu stoppet og fjernet.${NC}"
else
    echo "Der opstod en fejl under stop-processen."
    exit 1
fi