#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SP4="$DIR/sp4"

GAP=0

run() {
  local file="$1" duration="$2"
  echo "▶  $file"
  "$SP4" "run_file \"$DIR/$file\""
  sleep "$duration"
  "$SP4" stop 2>/dev/null || true
  sleep "$GAP"
}

#                          music   +5s buffer
run "0. intro.rb"            53   #  ~48s procedural
run "1. fault.rb"           120   #  115s @ 175 BPM
run "interlude_1.rb"         91   #  B  — Static March      (~1.5 min)
run "2. edge.rb"            141   #  136s @ 148 BPM
run "interlude_2.rb"        131   #  Em — Half-Time Gallop  (~2.2 min)
run "3. void.rb"            176   #  171s @ 118 BPM
run "interlude_3.rb"         66   #  Ab — Doom March        (~1.1 min)
run "4. disco.rb"            89   #   84s @ 240 BPM
run "5. polka.rb"           129   #  124s @ 185 BPM (jaunty D major)
run "interlude_4.rb"        116   #  Bb — Pressure Drop     (~2 min)
run "6. coil.rb"            131   #  126s @ 160 BPM
run "interlude_5.rb"        179   #  F# — Broken Machine    (~2.8 min)
run "7. wire.rb"            128   #  123s @ 164 BPM
run "8. lightsaber.rb"      124   #  119s @ 185 BPM (cover — Lightsabre Cocksucking Blues)
run "9. final.rb"           413   #  288s @ 70 BPM + ~2 min G chord hold

echo "Set complete — stop the recorder."
