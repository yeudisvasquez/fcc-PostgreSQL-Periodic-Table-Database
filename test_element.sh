#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/periodic_table/element.sh"

run_test() {
  input=$1
  expected=$2
  out=$(bash "$SCRIPT" "$input")
  if [[ "$out" != "$expected" ]]; then
    echo "Test failed for input '$input'"
    echo "Expected: $expected"
    echo "Got:      $out"
    exit 2
  fi
}

echo "Running tests..."
run_test H "1 | H | Hydrogen | 1.008"
run_test 1 "1 | H | Hydrogen | 1.008"
run_test Hydrogen "1 | H | Hydrogen | 1.008"

echo "All tests passed."
