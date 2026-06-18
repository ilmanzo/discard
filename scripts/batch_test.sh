#!/usr/bin/env bash
# Batch-test all levels: select → solve → check --batch
# Exit 0 if all pass, 1 if any fail.

set -euo pipefail

DISCARD="./discard"
STATE_FILE=".discard_state"
CACHE_FILE=".discard_cache"

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

LEVELS=(0 1 2 3 4 5 6 7 8 9 10 11 12)
PASS=0
FAIL=0
ERRORS=()

# Save current state
saved_state=""
if [[ -f "$STATE_FILE" ]]; then
  saved_state=$(cat "$STATE_FILE")
fi

restore_state() {
  if [[ -n "$saved_state" ]]; then
    echo "$saved_state" > "$STATE_FILE"
  else
    rm -f "$STATE_FILE"
  fi
  rm -f "$CACHE_FILE"
}
trap restore_state EXIT

# Reset to clean state before testing
"$DISCARD" reset all > /dev/null 2>&1 || true
rm -f "$CACHE_FILE"

# Build discard if needed
if [[ ! -x "$DISCARD" ]]; then
  echo -e "${YELLOW}Building discard...${RESET}"
  nim c --hints:off --warnings:off discard.nim
fi

echo -e "${YELLOW}Running batch test across ${#LEVELS[@]} levels...${RESET}"
echo ""

for lvl in "${LEVELS[@]}"; do
  printf "  Level %2d  " "$lvl"

  # Select + load reference solution
  "$DISCARD" select "$lvl" > /dev/null 2>&1
  "$DISCARD" solve > /dev/null 2>&1

  # Run check in batch mode (no animation, exits with code)
  if "$DISCARD" check --batch > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${RESET}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${RESET}"
    FAIL=$((FAIL + 1))
    ERRORS+=("$lvl")
  fi
done

echo ""
echo -e "Results: ${GREEN}${PASS} passed${RESET}  ${RED}${FAIL} failed${RESET}"

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo -e "${RED}Failed levels: ${ERRORS[*]}${RESET}"
  exit 1
fi
