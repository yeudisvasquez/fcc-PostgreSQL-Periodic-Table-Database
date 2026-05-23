#!/bin/bash

# Usage message
usage() {
  echo "Usage: $0 <atomic_number|symbol|name>"
  echo "Examples: $0 1, $0 H, $0 Hydrogen"
  exit 1
}

# Check if argument is provided
if [[ -z $1 ]]; then
  usage
fi

# Get the data directory (where this script is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATA_FILE="$SCRIPT_DIR/../atomic_mass.txt"

# Ensure data file exists
if [[ ! -f "$DATA_FILE" ]]; then
  echo "Data file not found: $DATA_FILE" >&2
  exit 2
fi

# Element data (atomic_number | symbol | name)
declare -A ELEMENTS=(
  [1]="H Hydrogen"
  [2]="He Helium"
  [3]="Li Lithium"
  [4]="Be Beryllium"
  [5]="B Boron"
  [6]="C Carbon"
  [7]="N Nitrogen"
  [8]="O Oxygen"
  [9]="F Fluorine"
  [10]="Ne Neon"
)

# Function to get atomic mass from file
get_mass() {
  local num=$1
  awk -F'|' -v n="$num" '{
    # remove spaces from field 1
    gsub(/ /, "", $1)
    if ($1 == n) {
      # trim whitespace from field 2
      gsub(/^[ \t]+|[ \t]+$/, "", $2)
      print $2
    }
  }' "$DATA_FILE"
}

# Try to find the element by number, symbol, or name
input="$1"
input_lc="$(echo "$input" | tr '[:upper:]' '[:lower:]')"

for num in "${!ELEMENTS[@]}"; do
  read -r symbol name <<< "${ELEMENTS[$num]}"
  symbol_lc="$(echo "$symbol" | tr '[:upper:]' '[:lower:]')"
  name_lc="$(echo "$name" | tr '[:upper:]' '[:lower:]')"

  if [[ "$input" == "$num" ]] || [[ "$input_lc" == "$symbol_lc" ]] || [[ "$input_lc" == "$name_lc" ]]; then
    mass=$(get_mass "$num")
    if [[ -z "$mass" ]]; then
      mass="unknown"
    fi
    echo "$num | $symbol | $name | $mass"
    exit 0
  fi
done

echo "I could not find that element in the database." >&2
usage
