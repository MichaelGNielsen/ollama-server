# Ollama Docker Commands

## Startup & Management

| Action | Command |
| :--- | :--- |
| Start Ollama (GPU) | `docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama` |
| Pull Model | `docker exec -it ollama ollama pull gemma4:31b` |
| Run Model | `docker exec -it ollama ollama run qwen3.6` |
| List Models | `docker exec -it ollama ollama list` |
| Stop Container | `docker stop ollama` |
| Remove Container | `docker rm ollama` |
| unload model i ollama | `curl http://localhost:11434/api/generate -d '{ "model": "gemma4:31b", "keep_alive": 0 }' |
| run nemotron-3-ultra:cloud |`ollama run nemotron-3-ultra:cloud`|
| run glm-5.2:cloud | `docker exec -it ollama ollama run glm-5.2:cloud` |


# hold model loaded i 24 timer

```bash

#input til ollama, load qwen3.6 i en time 

curl http://localhost:11434/api/generate -d '{
  "model": "qwen3.6",
  "keep_alive": "1h"
}'

#output 

{"model":"qwen3.6","created_at":"2026-06-26T16:43:24.654667385Z","response":"","done":true,"done_reason":"load"}
```