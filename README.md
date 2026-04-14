# Ollama Server Setup

Denne repository indeholder en simpel opsætning af en **Ollama server** via Docker Compose. Den er designet til at køre lokalt på din PC (WSL2/Linux) og kan bruges af andre services til AI-opgaver.

## Teknisk Overblik
Ollama er et værktøj, der gør det muligt at køre store sprogmodeller (LLMs) som Llama 3, Mistral og Phi-3 direkte på din egen hardware uden behov for en cloud-løsning.

- **Port:** Serveren kører på port `11434` (forskudt fra standardport 11434 for at undgå konflikter, hvis du også kører Ollama nativt på din host-maskine/WSL).
- **Persistens:** Dine hentede modeller bliver gemt i en Docker volume (`ollama_data`), så de ikke skal hentes igen, når containeren genstartes.

## Opstart af Serveren

For at starte din Ollama server, skal du køre følgende kommando i din terminal:

```bash
docker-compose up -d
```

Dette vil starte serveren i baggrunden.

## Hent og kør en model

Da denne maskine har **8GB RAM** og kører på **CPU**, anbefales det at bruge mindre modeller for den bedste oplevelse.

### Anbefalet model: Phi-3 (Lynhurtig på CPU)
Microsofts **Phi-3** er en lille, men kraftfuld model, der fungerer rigtig godt uden et grafikkort (GPU).

Kør denne kommando for at hente og tale med modellen:
```bash
docker exec -it ollama ollama run phi3
docker exec -it ollama ollama run llama3.2:3b
docker exec -it ollama ollama run gemma3:4b
docker exec -it ollama ollama run gemma2:9b
docker exec -it ollama ollama run llama3.1:8b
```

### Scripted Model Downloads

For nemmere administration af model downloads, kan du bruge et hjælpescript `pull_models.sh`. Dette script indeholder de tidligere nævnte `docker exec` kommandoer til at hente flere modeller på én gang.

Kør scriptet fra roden af projektet:
```bash
./pull_models.sh
```

Dette script vil køre kommandoerne for at hente følgende modeller:
- `gemma3:4b` (automatisk ved serverstart via `docker-compose.yml`)
- `gemma2:9b`
- `phi3`
- `llama3.2:3b`
- `llama3.1:8b`


### Andre gode modeller til din hardware:
- **Llama 3 (8B):** Den nyeste standard fra Meta. Kan være lidt tung på CPU, men er meget klog.
  ```bash
  docker exec -it ollama ollama run llama3
  ```
- **Mistral (7B):** En god all-round model.
  ```bash
  docker exec -it ollama ollama run mistral
  ```

## Vedvarende Modeller og Genstart

Denne opsætning er konfigureret til at være selvkørende:

- **Automatisk Opstart:** Da containeren er sat til `restart: unless-stopped`, vil Ollama-serveren starte automatisk op hver gang din computer eller Docker-tjenesten genstartes (medmindre du manuelt har stoppet den med `docker-compose down`).
- **Modeller Gemmes:** Alle modeller, du henter (f.eks. med `ollama run phi3`), bliver gemt permanent i Docker-volumen `ollama_data`. Du skal derfor kun hente dem én gang.
- **Hukommelsesforbrug:** Selvom serveren kører i baggrunden, indlæses modellerne normalt først i RAM, når de bliver kaldt. Det betyder, at din PC ikke bliver sløv af, at serveren blot kører i baggrunden uden at være i brug.

## Integration med andre services
Du kan forbinde til din Ollama server fra andre applikationer ved at pege dem mod:
`http://localhost:11434` (eller IP-adressen på din maskine).

## Stop serveren
Når du er færdig med at bruge serveren, kan du stoppe den for at frigive RAM og CPU-ressourcer:
```bash
docker-compose down
```

**Projekt Kontrakt:**
- [GEMINI.md](/GEMINI.md)

*Bemærk: Filen `GEMINI.md` indeholder projektets overordnede kontrakt og workflow.*