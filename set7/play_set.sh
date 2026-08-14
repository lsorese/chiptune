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
run "0. intro.rb"            53   #   48s procedural (unchanged from set6)
run "1. fault.rb"            94   #   89s  175 → 200 BPM   Bm → Dm
run "interlude_1.rb"         77   #   72s  160 BPM  B  — Static March
run "2. edge.rb"            105   #  100s  148 → 100 → 168 Cm → Fm
run "interlude_2.rb"        101   #   96s  140 BPM  Em — Half-Time Gallop
run "3. void.rb"            116   #  111s  88 → 118 → 158  Ebm → Bbm
run "interlude_3.rb"         53   #   48s  120 BPM  Ab — Doom March
run "4. disco.rb"            63   #   59s  240 → 120 → 260 B → G → C
run "5. polka.rb"            90   #   85s  170 → 225 accel  D → G → E
run "interlude_4.rb"         91   #   86s  200 BPM  Bb — Pressure Drop
run "6. coil.rb"             96   #   91s  160 → 128 → 172 F#m7 → Am7
run "interlude_5.rb"        135   #  130s  162 BPM  F# — Broken Machine
run "7. wire.rb"            101   #   97s  164 → 88 → 172   G#m → Bm
run "8. lightsaber.rb"      124   #  119s  185 BPM (cover — untouched from set6)
run "9. final.rb"           265   #  201s  60 → 96 → 56  Am → Dm → A major
                                  #        + 60s held A major coda

echo "Set complete — stop the recorder."
