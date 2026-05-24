#!/usr/bin/env bash
set -e

SP4="/Users/logan/Projects/chiptune/set5/sp4"
DIR="/Users/logan/Projects/chiptune/set6"

GAP=1

run() {
  local file="$1" duration="$2"
  echo "▶  $file"
  "$SP4" "run_file \"$DIR/$file\""
  sleep "$duration"
  "$SP4" stop 2>/dev/null || true
  sleep "$GAP"
}

#                  music    +15s buffer
run "0. intro.rb"    55    #  ~48s procedural
run "1. fault.rb"   131    #  115s @ 175 BPM
run "interlude_1.rb"  93   #  B  — Static March      (~1.5 min)
run "2. edge.rb"    152    #  136s @ 148 BPM
run "interlude_2.rb" 133   #  Em — Half-Time Gallop  (~2.2 min)
run "3. void.rb"    186    #  171s @ 118 BPM
run "interlude_3.rb"  68   #  Ab — Doom March        (~1.1 min, short + heavy)
run "4. disco.rb"    99    #   84s @ 240 BPM (two rounds, 64-beat disco each)
run "interlude_4.rb" 118   #  Bb — Pressure Drop     (~2 min, escalates to blast)
run "5. coil.rb"    142    #  126s @ 160 BPM
run "interlude_5.rb" 181   #  F# — Broken Machine    (~2.8 min, full song)
run "6. wire.rb"    139    #  123s @ 164 BPM
run "7. final.rb"   420    #  288s @ 70 BPM + ~2 min G chord hold

echo "Set complete — stop the recorder."
