#!/usr/bin/env bash
set -e

SP4="/Users/logan/Projects/chiptune/set4/sp4"
DIR="/Users/logan/Projects/chiptune/set4"

GAP=3

run() {
  local file="$1" duration="$2"
  echo "▶  $file"
  "$SP4" "run_file \"$DIR/$file\""
  sleep "$duration"
  "$SP4" stop 2>/dev/null || true
  sleep "$GAP"
}

run "0. intro.rb"  40
run "1. fault.rb"  102
run "2. edge.rb"   120
run "3. void.rb"   148
run "4. coil.rb"   112
run "5. wire.rb"   108
run "6. final.rb"  285

echo "Set complete — stop the recorder."
