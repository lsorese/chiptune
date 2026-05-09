#!/usr/bin/env bash
set -e

SP4="/Users/logan/Projects/chiptune/set5/sp4"
SCRIPT_DIR="/Users/logan/Projects/chiptune/set5"
OUT="$SCRIPT_DIR/wavs/set5_full.wav"

mkdir -p "$SCRIPT_DIR/wavs"

GAP=3

declare -a TRACKS=(
  "0. intro.rb:40"
  "1. fault.rb:102"
  "2. edge.rb:120"
  "3. void.rb:148"
  "4. coil_v5.rb:112"
  "5. wire.rb:108"
  "6. final.rb:285"
)

echo "Starting full-set recording → $OUT"
"$SP4" start-recording
sleep 1

for entry in "${TRACKS[@]}"; do
  file="${entry%%:*}"
  duration="${entry##*:}"
  echo "  ▶  $file"
  "$SP4" "run_file \"$SCRIPT_DIR/$file\""
  sleep "$duration"
  "$SP4" stop 2>/dev/null || true
  sleep "$GAP"
done

"$SP4" stop-recording
sleep 1
"$SP4" save-recording "$OUT"
sleep 1

echo "Done → $OUT"
