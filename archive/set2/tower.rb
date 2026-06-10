# tower.rb
# 112 BPM  |  F# minor  |  F#m – D – A – E
#
# Doom pace. Blade synth chord drones throughout (heavy reverb + echo).
# Half-note bass. Kick every beat. Crash swell on every bar. No hats.
# Cyber metal — space for screamed vocals.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/set2/tower.rb"

use_bpm 112

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Chord drones (blade synth, both sections) ─────────────────────────────────
# 2 passes × 4 chords × sleep 4 = 32 beats ✓
CHORD_PADS = [
  [:fs4, :a4, :cs5],   # F#m
  [:d4,  :fs4, :a4],   # D
  [:a3,  :cs4, :e4],   # A major
  [:e4,  :gs4, :b4],   # E major
]

live_loop :pads, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :reverb, room: 0.98, mix: 0.65 do
    with_fx :echo, phase: 2.0, decay: 3.0, mix: 0.12 do
      use_synth :blade
      use_synth_defaults attack: 0.8, sustain: 2.5, release: 0.8,
                         amp: 0.35, vibrato_rate: 0.8, vibrato_depth: 0.12
      2.times do
        CHORD_PADS.each do |chord|
          chord.each { |n| play n }
          sleep 4
        end
      end
    end
  end
end

# ── Half-note bass (root–fifth, 32 beats) ─────────────────────────────────────
# 2 passes × 4 chords × (sleep2 + sleep2) = 32 beats ✓
BASS_ROOTS  = [:fs1, :d2, :a1, :e2]
BASS_FIFTHS = [:cs2, :a2, :e2, :b2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.9, release: 0.2, amp: 2.2
    2.times do
      BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
        play root;  sleep 2
        play fifth; sleep 2
      end
    end
  end
end

# ── Kick (every beat, doom march, 32 beats) ───────────────────────────────────
# 32 × sleep 1 = 32 ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  32.times do
    sample :bd_haus, amp: 2.0
    sleep 1
  end
end

# ── Snare (heavy 2+4, 32 beats) ───────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 1
    sample :sn_dolf, amp: 2.6, rate: 0.78
    sleep 2
    sample :sn_dolf, amp: 2.6, rate: 0.76
    sleep 1
  end
end

# ── Crash swell (every bar downbeat, 32 beats) ────────────────────────────────
# 8 bars × sleep 4 = 32 ✓
live_loop :crash, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sample :drum_cymbal_open, amp: 0.7, finish: 0.5
    sleep 4
  end
end
