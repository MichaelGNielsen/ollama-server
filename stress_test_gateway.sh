#!/bin/bash

# ==========================================================
#  AI-Gateway System-Stress-Test v1.0
#  Tester Concurrency ved at sende 6 parallelle foresp\u00f8rgsler
# ==========================================================

MODEL="gemma4:26b"
GATEWAY_URL="http://localhost:4042/api/ask"

echo "=========================================================="
echo " \ud83d\udea6 AI-GATEWAY CONCURRENCY STRESS TEST"
echo " Sender 6 parallelle jobs mod 4 ledige slots..."
echo "=========================================================="

run_single_job() {
    local ID=$1
    local CID="stress-job-$ID"
    local PROMPT="Hvad er 2+$ID? Svar med et tal."

    local START=$(date +%s)
    # Byg JSON via Python for at sikre 100% valid formatering
    local JSON_DATA=$(python3 -c "import json, sys; print(json.dumps({'prompt': sys.argv[1], 'cid': sys.argv[2], 'model': sys.argv[3]}))" "$PROMPT" "$CID" "$MODEL")

    local RESPONSE=$(curl -s -X POST "$GATEWAY_URL" \
        -H "Content-Type: application/json" \
        -d "$JSON_DATA")
    local END=$(date +%s)
    
    local DURATION=$((END - START))
    if echo "$RESPONSE" | grep -q '"answer":'; then
        echo "[Job $ID] SUCCESS: F\u00e6rdig p\u00e5 $DURATION sekunder (CID: $CID)"
    else
        echo "[Job $ID] FEJL: $RESPONSE"
    fi
}

for i in {1..6}; do
    run_single_job "$i" &
done

echo "Jobs er sendt. Vent p\u00e5 resultater..."
wait
echo "=========================================================="
echo "Stress-test f\u00e6rdig!"
