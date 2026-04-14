#!/bin/bash

# Liste over modeller
MODELS=(
  "gemma2:9b"
  "phi3"
  "llama3.2:3b"
  "llama3.1:8b"
  "llama3.1:latest"
  "gemma4:e2b"
  "gemma4:e4b"
  "gemma4:latest"
  "gemma4:26b"
  "gemma4:31b"
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