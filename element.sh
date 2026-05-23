#!/bin/bash

# -------------------------
# Usage
# -------------------------
if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

input="$1"

# -------------------------
# Query PostgreSQL
# -------------------------
result=$(psql -U postgres -d periodic_table -t -A -F'|' <<EOF
SELECT
  e.atomic_number,
  e.symbol,
  e.name,
  t.type,
  p.atomic_mass,
  p.melting_point_celsius,
  p.boiling_point_celsius
FROM elements e
JOIN properties p ON e.atomic_number = p.atomic_number
JOIN types t ON p.type_id = t.type_id
WHERE
  e.atomic_number::text = '$input'
  OR LOWER(e.symbol) = LOWER('$input')
  OR LOWER(e.name) = LOWER('$input')
LIMIT 1;
EOF
)

# -------------------------
# Not found
# -------------------------
if [[ -z "${result// }" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# -------------------------
# Parse result
# -------------------------
IFS="|" read -r atomic_number symbol name type mass melt boil <<< "$result"

# -------------------------
# Output (exact format)
# -------------------------
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $mass amu. $name has a melting point of $melt celsius and a boiling point of $boil celsius."
