# Netværkskonfiguration (mcp-network)

Dette dokument beskriver, hvordan Ollama-serveren håndterer netværksforbindelsen til andre tjenester (f.eks. AI-Gateway / MCP-servere fra GlobalSentinel).

## Udfordringen med `mcp-network`

I `docker-compose.yml` er Ollama konfigureret til at tilslutte sig et eksternt netværk kaldet `mcp-network`:

```yaml
networks:
  gs-network:
    external: true
    name: mcp-network
```

Fordi netværket er markeret som `external: true`, forventer Docker Compose, at netværket allerede eksisterer på værtsmaskinen. 
- På maskiner som **NUC5** (hvor GlobalSentinel kører og har oprettet netværket), virker dette uden problemer.
- På maskiner som **NUC1** (hvor GlobalSentinel ikke kører), eksisterede netværket ikke. Dette fik Docker Compose til at fejle under opstart med fejlen:
  `network mcp-network declared as external, but could not be found`

## Løsningen

For at gøre opsætningen robust og uafhængig af, hvilken maskine den kører på, har vi tilføjet en automatisk netværkskontrol i start-scriptet [start.sh](../start.sh):

```bash
# Sørg for, at mcp-network eksisterer
docker network inspect mcp-network >/dev/null 2>&1 || docker network create mcp-network
```

### Hvordan det fungerer i praksis:
1. **Hvis det rigtige netværk findes (f.eks. oprettet af GlobalSentinel):**
   `start.sh` opdager, at `mcp-network` allerede eksisterer, og foretager sig intet. Ollama starter op og forbinder sig til det eksisterende netværk.
2. **Hvis netværket mangler (f.eks. på en ren NUC1 opsætning):**
   `start.sh` opretter automatisk et lokalt "snyde"-netværk (dummy network) med navnet `mcp-network`. Ollama starter herefter uden fejl. Hvis GlobalSentinel-tjenesterne på et senere tidspunkt startes op, vil de automatisk koble sig på dette fælles netværk.
