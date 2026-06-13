#!/bin/bash

# ==========================================================
#  AI-Gateway Correlation ID Benchmark v1.2
#  Tester real-world scenarier med Tracking IDs (cid)
# ==========================================================

MODEL="gemma4:26b"
GATEWAY_URL="http://localhost:4042/api/ask"

echo "=========================================================="
echo " Starting AI-GATEWAY CID Tracking Benchmark"
echo " Target: $GATEWAY_URL | Model: $MODEL"
echo "=========================================================="
printf "%-15s | %-12s | %-20s | %-10s\n" "Kilde" "Test Type" "Tracking ID (cid)" "Tid (s)"
echo "--------------------------------------------------------------------------"

run_gateway_test() {
    local TYPE=$1
    local PROMPT="Dette er en test af tracking systemet for $TYPE."
    local CID="bench-$TYPE-$(date +%M%S)"

    JSON_BODY=$(python3 -c "import json, sys; print(json.dumps({'prompt': sys.argv[1], 'cid': sys.argv[2], 'model': sys.argv[3], 'provider': 'ollama'}))" "$PROMPT" "$CID" "$MODEL")

    START=$(date +%s.%N)
    RESPONSE=$(curl -s -X POST "$GATEWAY_URL" -H "Content-Type: application/json" -d "$JSON_BODY")
    END=$(date +%s.%N)

    DURATION=$(echo "$END - $START" | bc)
    
    RETURNED_CID=$(echo "$RESPONSE" | grep -o '"cid":"[^"]*"' | cut -d'"' -f4)

    if [ "$CID" == "$RETURNED_CID" ]; then
        printf "%-15s | %-12s | %-20s | %-10.1f\n" "AI-Gateway" "$TYPE" "$RETURNED_CID" "$DURATION"
    else
        printf "%-15s | %-12s | %-20s | %-10s\n" "AI-Gateway" "$TYPE" "FEJL" "FAIL"
        echo "DEBUG: Forventede $CID, fik $RETURNED_CID"
        echo "RESPONSE: $RESPONSE"
    fi
}

run_gateway_test "Aktie"
sleep 2
run_gateway_test "YouTube"

echo "--------------------------------------------------------------------------"
echo "Tracking-test f\u00e6rdig!"
