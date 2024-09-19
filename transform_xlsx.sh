#!/bin/bash

# Check if the input file is provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 input_file.xlsx [filter_column filter_substring cut_columns output_headers]"
  echo "Example: $0 input.xlsx 1 'buzz' '2,3' 'login,target_email'"
  exit 1
fi

# Input file and optional parameters
INPUT_FILE=$1
FILTER_COLUMN=${2:-""}           # If not provided, default to no filter
FILTER_SUBSTRING=${3:-""}        # If not provided, default to no filter
CUT_COLUMNS=${4:-""}             # If not provided, default to include all columns
OUTPUT_HEADERS=${5:-""}          # If not provided, no custom headers

# Temporary CSV file
TEMP_FILE="temp.csv"

# Output file with transformed data
OUTPUT_FILE="output.csv"

# Step 1: Convert XLSX to CSV
in2csv "$INPUT_FILE" > "$TEMP_FILE"

# Step 2: Apply filtering if filter column and substring are provided
if [ -n "$FILTER_COLUMN" ] && [ -n "$FILTER_SUBSTRING" ]; then
  csvgrep -c "$FILTER_COLUMN" -r "$FILTER_SUBSTRING" "$TEMP_FILE" > "filtered_$TEMP_FILE"
  mv "filtered_$TEMP_FILE" "$TEMP_FILE"
fi

# Step 3: Apply column cutting if cut_columns is provided
if [ -n "$CUT_COLUMNS" ]; then
  csvcut -c "$CUT_COLUMNS" "$TEMP_FILE" > "cut_$TEMP_FILE"
  mv "cut_$TEMP_FILE" "$TEMP_FILE"
fi

# Step 4: Add custom headers if provided
if [ -n "$OUTPUT_HEADERS" ]; then
  echo "$OUTPUT_HEADERS" | cat - "$TEMP_FILE" > "$OUTPUT_FILE"
else
  cp "$TEMP_FILE" "$OUTPUT_FILE"
fi

# Step 5: Clean up the temporary file
rm "$TEMP_FILE"

echo "Transformation complete. Output saved as $OUTPUT_FILE"

