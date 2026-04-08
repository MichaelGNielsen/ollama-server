# GEMINI.md

## Project Overview
This project provides a simple, standalone **Ollama server** configuration for local AI inference. It is designed to be a lightweight backend for any service requiring local LLM calls.

### Core Technologies
- **Ollama:** The underlying LLM server for running models like Llama 3, Mistral, and others.
- **Docker Compose:** Used for container orchestration and environment isolation.

## Infrastructure & Configuration
The setup consists of a single service running the official Ollama image.

- **Port:** Exposes `11434` for API and UI interactions.
- **Persistence:** Uses a Docker volume named `ollama_data` to store downloaded models and configuration across container restarts.

## Operational Commands

### Starting the Server

To start the Ollama server in detached mode:

```bash
docker-compose up -d
```

### Stopping the Server

To stop and remove the containers:
```bash
docker-compose down
```

### Monitoring Logs
To follow the server output and model loading progress:
```bash
docker-compose logs -f
```

### Pulling Models
Once the server is running, you can pull models using the `docker exec` command:
```bash
docker exec -it ollama ollama run llama3
```

## Development Conventions
- **Simplicity:** Keep the configuration minimal to serve as a reliable base for other projects.
- **Resource Management:** Ensure `docker-compose down` is used when the server is not needed to free up system resources (CPU/GPU/RAM).
