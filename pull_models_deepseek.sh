#!/bin/bash

# Liste over modeller
MODELS=(
  "deepseek-v4-flash:cloud"
  "deepseek-r1:1.5b"
  "deepseek-r1:latest"
  "deepseek-r1:32b"
)

for model in "${MODELS[@]}"; do
  echo "--------------------------------------------"
  echo "Begynder download af: $model"
  echo "Tidspunkt: $(date +%H:%M:%S)"
  
  # Vi fjerner -it her for at undgå problemer i scripts
  docker exec ollama ollama pull "$model"
  
  echo "Færdig med $model. Venter 1 sekunder..."
  sleep 1
done

echo "Alle modeller er forsøgt hentet!"