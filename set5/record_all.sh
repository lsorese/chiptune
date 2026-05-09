#!/usr/bin/env bash
set -e

SP4="/Users/logan/Projects/chiptune/set5/sp4"
SCRIPT_DIR="/Users/logan/Projects/chiptune/set5"
WAVS_DIR="$SCRIPT_DIR/wavs"

mkdir -p "$WAVS_DIR"

run_track() {
  local file="$1"
  local duration="$2"
  local name wav
  name="$(basename "$file" .rb)"
  wav="$WAVS_DIR/${name}.wav"

  echo ""
  echo "▶  $name  (${duration}s)"

  "$SP4" start-recording
  sleep 1

  "$SP4" "run_file \"$file\""
  sleep "$duration"

  "$SP4" stop-recording
  sleep 1
  "$SP4" save-recording "$wav"
  sleep 1

  "$SP4" stop 2>/dev/null || true
  sleep 2

  echo "   saved → $wav"
}

run_track "$SCRIPT_DIR/0. intro.rb"  40
run_track "$SCRIPT_DIR/1. fault.rb"  102
run_track "$SCRIPT_DIR/2. edge.rb"   120
run_track "$SCRIPT_DIR/3. void.rb"   148
run_track "$SCRIPT_DIR/4. coil_v5.rb"   112
run_track "$SCRIPT_DIR/5. wire.rb"   108
run_track "$SCRIPT_DIR/6. final.rb"  285

echo ""
echo "Done. WAVs are in $WAVS_DIR/"
