#!/usr/bin/env bash
# record_all.sh — renders each set4 track to WAV using Sonic Pi's internal recorder
#
# Requires: Sonic Pi 4 running
# Usage: bash record_all.sh

set -e

SP4="/Users/logan/Projects/chiptune/set4/sp4"
SCRIPT_DIR="/Users/logan/Projects/chiptune/set4"
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

# durations = (16 + SONG_END×32) beats ÷ BPM × 60  + 8s buffer
run_track "$SCRIPT_DIR/0. intro.rb"  40
run_track "$SCRIPT_DIR/1. fault.rb"  102
run_track "$SCRIPT_DIR/2. edge.rb"   120
run_track "$SCRIPT_DIR/3. void.rb"   148
run_track "$SCRIPT_DIR/4. coil.rb"   112
run_track "$SCRIPT_DIR/5. wire.rb"   108
run_track "$SCRIPT_DIR/6. final.rb"  285

echo ""
echo "Done. WAVs are in $WAVS_DIR/"
