#!/usr/bin/env bash
# record_all.sh — renders each set4 track to a WAV via Background Music capture
#
# Requires:
#   - Sonic Pi 4 running (and outputting through your system audio)
#   - Background Music app running (https://github.com/kyleneideck/BackgroundMusic)
#   - sonic_pi4 in PATH  (~/.gem/ruby/2.6.0/bin/sonic_pi4)
#   - ffmpeg in PATH
#
# Usage: bash record_all.sh

set -e

SP4="/Users/logan/Projects/chiptune/set4/sp4"
SCRIPT_DIR="/Users/logan/Projects/chiptune/set4"
WAVS_DIR="$SCRIPT_DIR/wavs"
AUDIO_INPUT=":0"   # Background Music, index 0 in avfoundation

mkdir -p "$WAVS_DIR"

run_track() {
  local file="$1"
  local duration="$2"
  local name
  name="$(basename "$file" .rb)"
  local wav="$WAVS_DIR/${name}.wav"

  echo ""
  echo "▶  $file  (${duration}s)"

  # start capturing system audio
  ffmpeg -y -loglevel warning \
    -f avfoundation -i "$AUDIO_INPUT" \
    -t "$duration" \
    -acodec pcm_s16le -ar 44100 \
    "$wav" &
  local ffpid=$!

  # brief lead-in so ffmpeg is ready before the track starts
  sleep 2

  # run the track in Sonic Pi
  "$SP4" "run_file \"$file\""

  # wait for the full recording window
  wait "$ffpid"

  # cut Sonic Pi after the track finishes
  "$SP4" stop 2>/dev/null || true

  echo "   saved → $wav"

  # pause between tracks so Sonic Pi settles
  sleep 3
}

# durations = (16 + SONG_END×32) beats ÷ BPM × 60  + 8s buffer
# intro.rb is a one-shot ~30-beat at 60 BPM = ~30s
run_track "$SCRIPT_DIR/0. intro.rb"  40
run_track "$SCRIPT_DIR/1. fault.rb"  102  # 272/175×60 ≈ 93s
run_track "$SCRIPT_DIR/2. edge.rb"   120  # 272/148×60 ≈ 110s
run_track "$SCRIPT_DIR/3. void.rb"   148  # 272/118×60 ≈ 138s
run_track "$SCRIPT_DIR/4. coil.rb"   112  # 272/160×60 ≈ 102s
run_track "$SCRIPT_DIR/5. wire.rb"   108  # 272/164×60 ≈ 100s
run_track "$SCRIPT_DIR/6. final.rb"  285  # 272/60×60  ≈ 272s

echo ""
echo "Done. WAVs are in $WAVS_DIR/"
