#!/bin/bash

# Funktion til at hente modellerne fra en valgt fil
process_file() {
    local FILE=$1
    echo "============================================"
    echo " Behandler liste: $FILE"
    echo "============================================"

    while read -r model || [ -n "$model" ]; do
        # Trim usynlige tegn og whitespaces
        model=$(echo "$model" | xargs)

        # Spring tomme linjer og kommentarer over
        if [ -z "$model" ] || [[ "$model" == \#* ]]; then
            continue
        fi

        echo "--------------------------------------------"
        echo "Begynder download af: $model"
        echo "Tidspunkt: $(date +%H:%M:%S)"
        
        # Henter modellen via Docker
        docker exec ollama ollama pull "$model"
        
        echo "Færdig med $model. Venter .1 sekund..."
        sleep .1
    done < "$FILE"
}

# Tjek om der kommer data ind via en PIPE (Standard Input)
if [ ! -t 0 ]; then
    # Læs de filnavne, der bliver pipet ind linje for linje
    while read -r piped_file; do
        if [ -f "$piped_file" ]; then
            process_file "$piped_file"
        else
            echo "ADVARSEL: Filen '$piped_file' findes ikke."
        fi
    done
else
    # Hvis der IKKE er en pipe, skal vi bruge et argument
    LIST_ARG=$1
    
    if [ -z "$LIST_ARG" ]; then
        echo "FEJL: Du skal enten pipe filer ind, eller angive et navn."
        echo "Format 1: ./pull-models.sh coding"
        echo "Format 2: ls -1 models-*.list | ./pull-models.sh"
        exit 1
    fi

    # Find filen baseret på argumentet (tjekker både direkte navn og den nye standard)
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

echo "============================================"
echo "Alt arbejde er fuldført!"
echo "============================================"