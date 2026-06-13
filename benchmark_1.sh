#!/bin/bash

MODELS=(
  "gemma4:e4b"
  "gemma4:12b"
  "gemma4:26b"
  "gemma4:31b"
  "qwen3.5"
  "llama3.1"
)

PROMPT_STOCK="Du er en finansiel analytiker. Analyser følgende data for aktien NVDA og giv en anbefaling [BUY/HOLD/SELL]. AKTIE: NVDA TEKNIK: Pris=130.00, SMA50=125.00, SMA200=110.00, RSI=65.0, RVOL=1.5, Markov=BULL. SEKTOR: Tech (Stigende)."
PROMPT_YT="Du er en AI-assistent der opsummerer video-indhold. Her er et uddrag fra en video om finansielle markeder. Giv en kort 'essence' og liste over 'tickers' nævnt i JSON format. TRANSKRIPT: 'Velkommen til dagens markedsoversigt. Vi kigger i dag på NVDA som har haft en vild uge. AMD følger trop men med mindre styrke. Jensen Huang udtalte i går at efterspørgslen på Blackwell chips er massiv. Samtidig ser vi Tesla kæmpe med marginerne i Kina. Apple har lanceret nye AI features der kan drive iPhone salget.'"

echo "=========================================================="
echo " REAL-WORLD Ollama Benchmark (NUC5 / NVIDIA GB10)"
echo "=========================================================="
printf "%-15s | %-12s | %-10s | %-10s
" "Model" "Type" "Tid (s)" "Tokens/s"
echo "----------------------------------------------------------"

run_test() {
    local MODEL=$1
    local TYPE=$2
    local PROMPT=$3

    # Sørg for modellen er klar
    docker exec -i ollama ollama pull "$MODEL" > /dev/null 2>&1

    # Byg JSON manuelt for at undgå escaping helvede
    JSON_BODY=$(cat <<EOF
{
  "model": "$MODEL",
  "prompt": "$PROMPT",
  "stream": false,
  "options": {
    "num_predict": 256,
    "num_ctx": 8192,
    "temperature": 0.1
  }
}
EOF
)

    START=$(date +%s.%N)
    RESPONSE=$(curl -s -X POST http://localhost:11434/api/generate         -H "Content-Type: application/json"         -d "$JSON_BODY")
    END=$(date +%s.%N)

    DURATION=$(echo "$END - $START" | bc)
    EVAL_COUNT=$(echo "$RESPONSE" | grep -o '"eval_count":[0-9]*' | cut -d: -f2)
    EVAL_DUR=$(echo "$RESPONSE" | grep -o '"eval_duration":[0-9]*' | cut -d: -f2)

    if [ -n "$EVAL_COUNT" ] && [ -n "$EVAL_DUR" ] && [ "$EVAL_DUR" -gt 0 ]; then
        TPS=$(awk "BEGIN {print ($EVAL_COUNT / ($EVAL_DUR / 1000000000))}")
        printf "%-15s | %-12s | %-10.1f | %-10.2f
" "$MODEL" "$TYPE" "$DURATION" "$TPS"
    else
        printf "%-15s | %-12s | %-10s | %-10s
" "$MODEL" "$TYPE" "FEJL" "N/A"
        # echo "DEBUG: $RESPONSE"
    fi
}

for MODEL in "${MODELS[@]}"; do
    run_test "$MODEL" "Aktie" "$PROMPT_STOCK"
    run_test "$MODEL" "YouTube" "$PROMPT_YT"
    echo "----------------------------------------------------------"
done
