#!/bin/bash

# ==========================================================
#  AI-Gateway Correlation ID Benchmark v1.1
#  Tester real-world scenarier med Tracking IDs (cid)
# ==========================================================

MODEL="gemma4:26b"
GATEWAY_URL="http://localhost:4042/api/ask"

echo "=========================================================="
echo " Starting AI-GATEWAY CID Tracking Benchmark"
echo " Target:  | Model: "
echo "=========================================================="
printf "%-15s | %-12s | %-15s | %-10s
" "Kilde" "Test Type" "Tracking ID (cid)" "Tid (s)"
echo "--------------------------------------------------------------------------"

run_gateway_test() {
    local TYPE=$1
    local PROMPT="Dette er en test af tracking systemet for $TYPE."
    local CID="bench-$TYPE-$(date +%M%S)"

    JSON_BODY=$(cat <<EOF
{
  "prompt": "$PROMPT",
  "cid": "$CID",
  "model": "$MODEL",
  "provider": "ollama"
}
EOF
)

    START=$(date +%s.%N)
    RESPONSE=$(curl -s -X POST "$GATEWAY_URL"         -H "Content-Type: application/json"         -d "$JSON_BODY")
    END=$(date +%s.%N)

    DURATION=$(echo "$END - $START" | bc)
    
    # Udtræk returned cid
    RETURNED_CID=$(echo "$RESPONSE" | grep -o '"cid":"[^"]*"' | cut -d'"' -f4)

    if [ "$CID" == "$RETURNED_CID" ]; then
        printf "%-15s | %-12s | %-15s | %-10.1f
" "AI-Gateway" "$TYPE" "$RETURNED_CID" "$DURATION"
    else
        printf "%-15s | %-12s | %-15s | %-10s
" "AI-Gateway" "$TYPE" "FEJL" "FAIL"
        echo "DEBUG: Forventede $CID, fik $RETURNED_CID"
    fi
}

run_gateway_test "Aktie"
run_gateway_test "YouTube"

echo "--------------------------------------------------------------------------"
echo "Tracking-test færdig!"
echo "Tjek nu loggen med: docker logs --tail 20 ai-gateway-mcp"
