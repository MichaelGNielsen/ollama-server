#!/bin/bash

# Definition af de modeller vi vil teste
MODELS=(
  "codegemma" 
  "gemma2" 
  "deepseek-r1:8b" 
  "llama3.1" 
  "llama3.2" 
  "gemma4:e2b" 
  "gemma4:e4b" 
  "gemma4:12b"
)

# Den fælles test-prompt
#PROMPT="Hvad er 2+2?"
PROMPT="Skriv en hurtig Python-funktion, der tjekker om en streng er et palindrom. Funktionen skal ignorere store/små bogstaver. Forklar logikken med én enkelt sætning."

echo "=========================================================="
echo " Starting Ollama Benchmark on NUC5 (NVIDIA GB10)"
echo "=========================================================="
echo ""

# Printer tabel-headere med det samme
printf "%-18s | %-20s | %-15s\n" "Modelnavn" "Status" "Tokens / sek"
echo "----------------------------------------------------------"

for MODEL in "${MODELS[@]}"; do
    # 1. Udskriv en ren statuslinje i tabellen uden at rydde skærmen endnu
    printf "%-18s | %-20s | %-15s\n" "$MODEL" "Henter/Klargør..." "-"

    # Hent modellen via Docker. Standard output skjules fra tabellen, men fejl vises.
    # Hvis den allerede er hentet, tager denne kommando under et halvt sekund.
    docker exec -i ollama ollama pull "$MODEL" > /dev/null 2>&1

    # Ryk én linje op og overskriv til API status, nu hvor download-støj er overstået
    echo -e "\033[1A\033[2K\033[1A"
    printf "%-18s | %-20s | %-15s\n" "$MODEL" "Kører API test..." "-"

    # 2. Kør selve testen via API'et
    RESPONSE=$(curl -s http://localhost:11434/api/generate -d "{
      \"model\": \"$MODEL\",
      \"prompt\": \"$PROMPT\",
      \"stream\": false
    }")

    # Udtræk eval_rate (tokens pr. sekund) fra JSON-svaret
    EVAL_COUNT=$(echo "$RESPONSE" | grep -o '"eval_count":[0-9]*' | cut -d: -f2)
    EVAL_DURATION=$(echo "$RESPONSE" | grep -o '"eval_duration":[0-9]*' | cut -d: -f2)

    if [ -n "$EVAL_COUNT" ] && [ -n "$EVAL_DURATION" ] && [ "$EVAL_DURATION" -gt 0 ]; then
        # Beregn tokens pr. sekund
        TOKENS_PER_SEK=$(awk "BEGIN {print ($EVAL_COUNT / ($EVAL_DURATION / 1000000000))}")
        TOKENS_PER_SEK=$(printf "%.2f" "$TOKENS_PER_SEK")
        STATUS="Succes"
    else
        TOKENS_PER_SEK="N/A"
        STATUS="Fejl i måling"
    fi

    # Ryk én linje op og udskriv det endelige, smukke resultat for denne model
    echo -e "\033[1A\033[2K\033[1A"
    printf "%-18s | %-20s | %-15s\n" "$MODEL" "$STATUS" "$TOKENS_PER_SEK t/s"
done

echo "----------------------------------------------------------"
echo "Benchmark færdig!"
