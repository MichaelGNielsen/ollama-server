#!/bin/bash

# Liste over modeller
MODELS=(
  "qwen3.5:9b"
  "qwen3.5:27b"
  "qwen3.5:latest"
  "qwen3-coder:latest"
  "qwen3:32b"
  "qwen3.5:35b"
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