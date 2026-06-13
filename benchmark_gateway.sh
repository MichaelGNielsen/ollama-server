#!/bin/bash

# ==========================================================
#  AI-Gateway System Integration Benchmark v1.0
#  Tester real-world scenarier GENNEM AI-Gateway
#  Dette simulerer faktisk produktionstrafik.
# ==========================================================

MODEL="gemma4:26b"
GATEWAY_URL="http://localhost:4042/api/ask"

# 1. Realistisk Aktie-Analyse
PROMPT_STOCK="Du er en finansiel analytiker. Analyser følgende data for aktien NVDA og giv en anbefaling [BUY/HOLD/SELL]. AKTIE: NVDA TEKNIK: Pris=130.00, SMA50=125.00, SMA200=110.00, RSI=65.0, RVOL=1.5, Markov=BULL. SEKTOR: Tech (Stigende)."

# 2. Realistisk YouTube Transkript
PROMPT_YT="Du er en AI-assistent der opsummerer video-indhold. Her er et uddrag fra en video om finansielle markeder. Giv en kort 'essence' og liste over 'tickers' nævnt i JSON format. TRANSKRIPT: 'Velkommen til dagens markedsoversigt. Vi kigger i dag på NVDA som har haft en vild uge. AMD følger trop men med mindre styrke. Jensen Huang udtalte i går at efterspørgslen på Blackwell chips er massiv. Samtidig ser vi Tesla kæmpe med marginerne i Kina. Apple har lanceret nye AI features der kan drive iPhone salget.'"

echo "=========================================================="
echo " Starting AI-GATEWAY Integration Benchmark"
echo " Target:  | Model: "
echo "=========================================================="
printf "%-15s | %-12s | %-10s | %-10s
" "Kilde" "Test Type" "Tid (s)" "Status"
echo "----------------------------------------------------------"

run_gateway_test() {
    local TYPE=$1
    local PROMPT=$2
    local SYS_INST="Svar kort og præcist."
    
    if [ "$TYPE" == "YouTube" ]; then
        SYS_INST="Du er en transskript-analytiker. Svar KUN i JSON format."
    fi

    JSON_BODY=$(cat <<EOF
{
  "prompt": "$PROMPT",
  "system_instruction": "$SYS_INST",
  "model": "$MODEL",
  "provider": "ollama",
  "force_json": false,
  "priority": false
}
EOF
)

    START=$(date +%s.%N)
    RESPONSE=$(curl -s -X POST "$GATEWAY_URL"         -H "Content-Type: application/json"         -d "$JSON_BODY")
    END=$(date +%s.%N)

    DURATION=$(echo "$END - $START" | bc)
    
    # Vi tjekker om 'answer' findes i JSON responsen
    if echo "$RESPONSE" | grep -q '"answer":'; then
        printf "%-15s | %-12s | %-10.1f | %-10s
" "AI-Gateway" "$TYPE" "$DURATION" "SUCCESS"
    else
        printf "%-15s | %-12s | %-10s | %-10s
" "AI-Gateway" "$TYPE" "FEJL" "FAIL"
        echo "DEBUG (RAW): $RESPONSE" | head -c 200
        echo ""
    fi
}

run_gateway_test "Aktie" "$PROMPT_STOCK"
run_gateway_test "YouTube" "$PROMPT_YT"

echo "----------------------------------------------------------"
echo "Integrationstest færdig!"
