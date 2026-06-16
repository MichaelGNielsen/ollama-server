#!/bin/bash

# ==========================================================
#  Ollama Docker Multi-Model Manager v2.1 (Skudsikker 32k)
# ==========================================================

CONTAINER_NAME="ollama"
TMP_FILE="Modelfile.docker.tmp"

# Funktion til at hente eller bygge modellerne fra en valgt fil
process_file() {
    local FILE=$1
    echo "=========================================================="
    echo " Behandler liste: $FILE"
    echo "=========================================================="

    while read -r model || [ -n "$model" ]; do
        # Trim usynlige tegn og whitespaces
        model=$(echo "$model" | xargs)

        # Spring tomme linjer og kommentarer over
        if [ -z "$model" ] || [[ "$model" == \#* ]]; then
            continue
        fi

        echo "----------------------------------------------------------"
        echo "Tidspunkt: $(date +%H:%M:%S)"

        # Tjek om modellen skal bygges som en 32k context-model
        if [[ "$model" == *"-32k"* ]]; then
            # Udtræk basisnavn og tag. F.eks: gemma4:12b-32k -> base_name="gemma4:12b"
            local BASE_TAG=$(echo "$model" | cut -d':' -f2 | sed 's/-32k//')
            local BASE_NAME=$(echo "$model" | cut -d':' -f1)
            local FULL_BASE="${BASE_NAME}:${BASE_TAG}"
            local NEW_MODEL_NAME="${BASE_NAME}-${BASE_TAG}:32k"

            if [[ "$BASE_TAG" == "latest" ]]; then
                NEW_MODEL_NAME="${BASE_NAME}-latest:32k"
                FULL_BASE="${BASE_NAME}:latest"
            fi

            echo "Detekteret 32k konfiguration for: $model"
            echo "--> 1. Henter basismodel: $FULL_BASE..."
            docker exec "$CONTAINER_NAME" ollama pull "$FULL_BASE"

            echo "--> 2. Opretter fysisk Modelfile til Docker..."
            # Skriv filen lokalt på hosten først
            echo "FROM $FULL_BASE" > "$TMP_FILE"
            echo "PARAMETER num_ctx 32768" >> "$TMP_FILE"

            # Kopier filen ind i containeren under /tmp
            docker cp "$TMP_FILE" "${CONTAINER_NAME}:/tmp/Modelfile"
            rm -f "$TMP_FILE" # Ryd op på hosten med det samme

            echo "--> 3. Bygger $NEW_MODEL_NAME internt i Docker via lokal fil..."
            if docker exec "$CONTAINER_NAME" ollama create "$NEW_MODEL_NAME" -f /tmp/Modelfile; then
                echo "--> [SUCCES] 32k model '$NEW_MODEL_NAME' er nu oprettet og klar i Docker!"
            else
                echo "--> [FEJL] Kunne ikke oprette 32k model '$NEW_MODEL_NAME'!"
            fi

            # Ryd op inde i containeren
            docker exec "$CONTAINER_NAME" rm -f /tmp/Modelfile

        else
            # Almindelig pull for standardmodeller
            echo "Begynder standard download af: $model"
            if docker exec "$CONTAINER_NAME" ollama pull "$model"; then
                echo "--> [SUCCES] Standard model hentet."
            else
                echo "--> [FEJL] Kunne ikke hente standard model."
            fi
        fi
        
        echo "Venter .1 sekund..."
        sleep .1
    done < "$FILE"
}

# Tjek om der kommer data ind via en PIPE (Standard Input)
if [ ! -t 0 ]; then
    while read -r piped_file; do
        if [ -f "$piped_file" ]; then
            process_file "$piped_file"
        else
            echo "ADVARSEL: Filen '$piped_file' findes ikke."
        fi
    done
else
    LIST_ARG=$1
    if [ -z "$LIST_ARG" ]; then
        echo "FEJL: Du skal enten pipe filer ind, eller angive et navn."
        exit 1
    fi

    if [ -f "./models-${LIST_ARG}.list" ]; then
        TARGET_FILE="./models-${LIST_ARG}.list"
    elif [ -f "./$LIST_ARG" ]; then
        TARGET_FILE="./$LIST_ARG"
    else
        echo "FEJL: Kunne ikke finde listen for '$LIST_ARG'"
        exit 1
    fi

    process_file "$TARGET_FILE"
fi

echo "=========================================================="
echo "Alt arbejde er fuldført!"
echo "=========================================================="
