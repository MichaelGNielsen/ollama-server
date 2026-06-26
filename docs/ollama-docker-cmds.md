# Ollama Docker Commands

## Startup & Management

| Action | Command |
| :--- | :--- |
| Start Ollama (GPU) | `docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama` |
| Pull Model | `docker exec -it ollama ollama pull <model_name>` |
| Run Model | `docker exec -it ollama ollama run <model_name>` |
| List Models | `docker exec -it ollama ollama list` |
| Stop Container | `docker stop ollama` |
| Remove Container | `docker rm ollama` |
|unload model i ollama | `curl http://localhost:11434/api/generate -d '{ "model": "your-model-name", "keep_alive": 0 }' |
