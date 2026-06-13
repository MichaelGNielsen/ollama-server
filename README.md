# Ollama Server — Docker setup

Ollama-server i Docker, designet til at køre på tværs af flere hardwareplatforme: **Raspberry Pi 5, Windows 11 og NVIDIA NUC5**.

## Hardwareplatforme

| Platform | GPU/accelerator | RAM/VRAM | Arkitektur |
|---|---|---|---|
| **NUC5 + ASUS GX10** | NVIDIA GB10 (Blackwell) | 128 GB unified | ARM64 (Grace) |
| **Win11 + RTX** | NVIDIA RTX (6 GB VRAM) | 6 GB VRAM | x86_64 |
| **Pi5 + Hailo10** | Hailo10 NPU (CPU-mode som default) | 8+ GB RAM | ARM64 |

Alle dele kører `ollama/ollama:latest` — Ollama understøtter både ARM64 og x86_64.

## Hurtig start

```bash
# NUC5:    cp .env.nuc5 .env   && ./start.sh
# Win11:   cp .env.win11 .env  && docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
# Pi5:     cp .env.pi5 .env    && docker compose up -d

# Hent modeller bagefter:
./pull-models.sh gemma4          # eller: gemma3, llama3, phi, qwen3, deepseek-r1
# Se alle modellister: ls models-*.list
```

## .env profiles

Vælg din platform og kopier den tilsvarende `.env.*` fil til `.env`:

| Profile | `cp` kommando | `NUM_CTX` | `NUM_PARALLEL` | Hardware |
|---|---|---|---|---|
| **Default** | `cp .env.example .env` | 8192 | 1 | Alle platforme |
| **NUC5 + GX10** | `cp .env.nuc5 .env` | **32768** | **4** | GB10, 128 GB unified |
| **Win11 + RTX 6GB** | `cp .env.win11 .env` | 8192 | 1 | RTX 6 GB VRAM |
| **Pi5 + Hailo10** | `cp .env.pi5 .env` | 8192 | 1 | ARM64 CPU-mode |

## Platform-specifikke detaljer

### NUC5 + ASUS GX10 (GB10 Blackwell)

```bash
cp .env.example .env
# Aktivér "NUC5 + ASUS GX10" profilet i .env
./start.sh    # vælger automatisk GPU via docker-compose.gpu.yml
```

- **GPU**: NVIDIA GB10 (Blackwell, CC 12.1) med unified memory — deler de 128 GB med CPU
- **num_ctx** 32K+ er muligt uden VRAM-begrænsning
- **num_parallel** 4+ udnytter GPU'en
- **Kræver**: `start.sh` (ikke `docker compose up`) for at aktivere GPU-override

Miljøvariabler sat af `.env`:
| Variabel | NUC5 | Forklaring |
|---|---|---|
| `OLLAMA_NUM_CTX` | 32768 | Maks kontekststørrelse (tokens) |
| `OLLAMA_NUM_PARALLEL` | 4 | Parallelle requests |
| `OLLAMA_KEEP_ALIVE` | 24h | Hold model i hukommelsen |

Anbefalede modeller: `gemma4:latest`, `llama3.3`, `deepseek-r1`, `qwen3`, `phi4`.

> **Bemærk**: Containeren forventer netværket `mcp-network`. `start.sh` opretter det automatisk.

### Windows 11 + RTX (6 GB VRAM)

```bash
# Aktivér "Win11 + RTX" profilet i .env
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
```

- **VRAM-begrænsning**: 6 GB sætter en grænse for modelstørrelse + kontekst
- `OLLAMA_NUM_CTX=8192` holder KV-cachen lille nok
- `OLLAMA_NUM_PARALLEL=1` undgår OOM
- NVIDIA GPU kræver `docker-compose.gpu.yml` (device reservation)
- WSL2: sørg for at Docker Desktop har NVIDIA Container Toolkit aktiveret

Anbefalede modeller: `gemma3:4b`, `phi3`, `llama3.2:3b`, `gemma2:2b`.

### Raspberry Pi 5 + Hailo10

```bash
# Aktivér "Pi5 + Hailo10" profilet i .env
docker compose up -d
```

- Kører i **CPU-mode** som udgangspunkt
- Hailo10 NPU kræver custom Ollama backend — ikke inkluderet her
- ARM64-image `ollama/ollama:latest` fungerer nativt
- Små modeller anbefales (phi3, llama3.2:3b)

## Miljøvariabler

| Variabel | Default | NUC5 | Win11 | Pi5 | Beskrivelse |
|---|---|---|---|---|---|
| `OLLAMA_NUM_CTX` | 8192 | 32768 | 8192 | 8192 | Maks kontekst (tokens) |
| `OLLAMA_NUM_PARALLEL` | 1 | 4 | 1 | 1 | Parallelle requests |
| `OLLAMA_KEEP_ALIVE` | 24h | 24h | 24h | 24h | Behold model i RAM/VRAM |

Sæt via `.env` eller som environment-variabel ved `docker compose`:
```bash
OLLAMA_NUM_CTX=16384 docker compose up -d
```

## Scripts

| Script | Funktion |
|---|---|
| `start.sh` | Starter server med auto-GPU-detektion |
| `stop.sh` | Stopper serveren |
| `pull-models.sh <kategori>` | Hent modeller fra `models-*.list` |
| `pull-models-all.sh` | Hent ALLE modeller fra alle `.list`-filer |
| `nvidia_check.sh` | Tjek om NVIDIA GPU er tilgængelig |

## Modeller

`models-*.list` filer indeholder modelnavne (ét pr. linje). Eksisterende kategorier:

```
models-gemma4.list         # gemma4:latest, gemma4:2b
models-gemma3n.list        # gemma3:4b, gemma3:1b, gemma3:12b, gemma3:27b
models-llama3.list         # llama3.2:3b, llama3.3, llama3.1:8b
models-phi.list            # phi3, phi4
models-qwen3.list          # qwen3:4b, qwen3:8b
models-deepseek-r1.list    # deepseek-r1:7b
```

Brug:
```bash
./pull-models.sh gemma4    # henter alle modeller i models-gemma4.list
./pull-models-all.sh       # henter ALLE modeller (vent jer — mange GB)
```

## Docker Compose filer

| Fil | Formål |
|---|---|
| `docker-compose.yml` | Base — virker på alle platforme (CPU-mode) |
| `docker-compose.gpu.yml` | NVIDIA GPU override (NUC5 + Win11) — tilføjer device reservations |

## Netværk

Ollama slutter sig til `mcp-network` (eksternt Docker-netværk). `start.sh` opretter det automatisk hvis det mangler.
Se [docs/netværk.md](docs/netværk.md) for detaljer.
