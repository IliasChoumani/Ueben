#!/bin/bash

# Datei definieren
FILE="bundesliga_player.csv"

# 1. Shape: Zeilenanzahl und Spaltenanzahl
ROWCOUNT=$(awk 'NF > 0' $FILE | wc -l)   # Zählt nur Zeilen mit Daten
COLUMNCOUNT=$(head -n 1 $FILE | sed 's/[^,]//g' | wc -c)

echo "Shape:"
echo "Rows: $ROWCOUNT"
echo "Columns: $COLUMNCOUNT"
echo ""

# 2. Spaltennamen
echo "Column Names:"
COLUMN_NAMES=$(head -n 1 $FILE)
echo "$COLUMN_NAMES" | awk -F, '{for(i=1;i<=NF;i++) print $i}'
echo ""

# 3. Datentypen und eindeutige Werte für jede Spalte bestimmen
echo "Column Data Types and Unique Values:"
echo "$COLUMN_NAMES" | awk -F, '{for(i=1;i<=NF;i++) print $i}' | while read -r col_name; do
    col_num=$(echo "$COLUMN_NAMES" | awk -F, -v col="$col_name" '{for(i=1;i<=NF;i++) if($i==col) print i}')
    col_data=$(cut -d, -f"$col_num" $FILE | tail -n +2)
    
    # Datentyp bestimmen (Numerisch/Textuell)
    if echo "$col_data" | grep -qE '^[0-9]+$'; then
        data_type="Numeric"
    else
        data_type="Textual"
    fi

    # Eindeutige Werte zählen
    unique_count=$(echo "$col_data" | sort | uniq | wc -l)
    
    echo "$col_name: $data_type"
    echo "Unique Values: $unique_count"
    echo ""
done
