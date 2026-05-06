#!/bin/bash

# Liste over modeller
MODELS=(
  "llama3.2:3b"
  "llama3.1:8b"
  "llama3.1:latest"
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