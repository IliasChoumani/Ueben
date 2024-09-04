#!/bin/bash

# Datei und Schwellenwert definieren
FILE="bundesliga_player.csv"
THRESHOLD=5
OUTPUT_MARKDOWN=false

# Funktion zur Anzeige von Usage-Informationen
usage() {
    echo "Usage: $0 [-m] [-f file] [-t threshold]"
    echo "  -m: Output in Markdown format"
    echo "  -f: Specify the CSV file (default: bundesliga_player.csv)"
    echo "  -t: Set the threshold for unique values (default: 5)"
    exit 1
}

# Argumente parsen
while getopts ":mf:t:" opt; do
  case $opt in
    m) OUTPUT_MARKDOWN=true ;;
    f) FILE=$OPTARG ;;
    t) THRESHOLD=$OPTARG ;;
    *) usage ;;
  esac
done

# Formatiertes Echo für Markdown
echo_md() {
    if $OUTPUT_MARKDOWN; then
        echo -e "$1"
    else
        echo "$2"
    fi
}

# Spaltennamen ermitteln
COLUMN_NAMES=$(head -n 1 $FILE)
echo_md "## Analysis of $FILE" "Analysis of $FILE"
echo_md "### Columns" "Columns"

# 1. Datentypen und Statistik pro Spalte bestimmen
echo "$COLUMN_NAMES" | awk -F, '{for(i=1;i<=NF;i++) print $i}' | while read -r col_name; do
    col_num=$(echo "$COLUMN_NAMES" | awk -F, -v col="$col_name" '{for(i=1;i<=NF;i++) if($i==col) print i}')
    col_data=$(cut -d, -f"$col_num" $FILE | tail -n +2 | grep -v '^$')  # Leere Zeilen ignorieren

    unique_count=$(echo "$col_data" | sort | uniq | wc -l)
    echo_md "#### $col_name" "$col_name"
    echo_md "- Unique Values: $unique_count" "Unique Values: $unique_count"

    # Für numerische Spalten
    if echo "$col_data" | grep -qE '^[0-9]+$'; then
        data_type="Numeric"
        max_value=$(echo "$col_data" | sort -n | tail -n 1)
        min_value=$(echo "$col_data" | sort -n | head -n 1)
        mean_value=$(echo "$col_data" | awk '{sum+=$1} END {print sum/NR}')
        median_value=$(echo "$col_data" | sort -n | awk 'NR%2{a=$1;getline;b=$1;print (a+b)/2;next}{print $1}')
        mode_value=$(echo "$col_data" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')

        echo_md "- Type: $data_type" "Type: $data_type"
        echo_md "- Min Value: $min_value" "Min Value: $min_value"
        echo_md "- Max Value: $max_value" "Max Value: $max_value"
        echo_md "- Mean: $mean_value" "Mean: $mean_value"
        echo_md "- Median: $median_value" "Median: $median_value"
        echo_md "- Mode: $mode_value" "Mode: $mode_value"

    else
        # Für textuelle Spalten
        data_type="Textual"
        mode_value=$(echo "$col_data" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
        echo_md "- Type: $data_type" "Type: $data_type"
        echo_md "- Mode: $mode_value" "Mode: $mode_value"
    fi

    # Wenn die Anzahl der eindeutigen Werte kleiner als der Schwellenwert ist, alle Werte ausgeben
    if [ "$unique_count" -lt "$THRESHOLD" ]; then
        unique_values=$(echo "$col_data" | sort | uniq | tr '\n' ', ' | sed 's/, $/\n/')
        echo_md "- Values: $unique_values" "Values: $unique_values"
    fi
    echo ""
done
