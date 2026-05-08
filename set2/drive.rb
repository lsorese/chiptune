# drive.rb
# 168 BPM  |  D minor  |  Dm – C – Bb – A
#
# Metal gallop bass (root–root–fifth 0.5+0.25+0.25). Power chord stabs in chorus.
# Double kick on 1+3. Constant 16th hats throughout.
# Cyber metal — space for screamed vocals.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/set2/drive.rb"

use_bpm 168

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Power chord stabs (chorus only — root + fifth, no third) ─────────────────
# 2 passes × 4 chords × sleep 4 = 32 beats ✓
POWER_STABS = [
  [:d4,  :a4],   # Dm5
  [:c4,  :g4],   # C5
  [:bb3, :f4],   # Bb5
  [:a3,  :e4],   # A5
]

live_loop :power_stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 8, sample_rate: 0.55 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.5, release: 0.2,
                         amp: 0.75, pulse_width: 0.3, cutoff: 88
      2.times do
        POWER_STABS.each do |chord|
          chord.each { |n| play n }
          sleep 4
        end
      end
    end
  else
    sleep 32
  end
end

# ── Gallop bass: root(0.5) + root(0.25) + fifth(0.25) = 1 beat per triplet ───
# 2 passes × 4 chords × 4 triplets × 1 beat = 32 beats ✓
BASS_ROOTS  = [:d2, :c2, :bb1, :a1]
BASS_FIFTHS = [:a2, :g2, :f2,  :e2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = [1, 3].include?(sec) ? 2.2 : 1.8
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.12, release: 0.04, amp: bass_amp
    2.times do
      BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
        4.times do
          play root;  sleep 0.5
          play root;  sleep 0.25
          play fifth; sleep 0.25
        end
      end
    end
  end
end

# ── Kick (double on beats 1+3, 32 beats) ──────────────────────────────────────
# 8 bars × (dbl + sleep1 + dbl + sleep1) = 8 × 4 = 32 ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sample :bd_haus, amp: 2.3; sleep 0.25
    sample :bd_haus, amp: 1.8; sleep 0.75
    sleep 1
    sample :bd_haus, amp: 2.3; sleep 0.25
    sample :bd_haus, amp: 1.8; sleep 0.75
    sleep 1
  end
end

# ── Snare (beats 2+4, 32 beats) ───────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 1
    sample :sn_dolf, amp: 2.2, rate: 0.92
    sleep 2
    sample :sn_dolf, amp: 2.4, rate: 0.9
    sleep 1
  end
end

# ── Hats (constant 16ths throughout, 32 beats) ────────────────────────────────
# 128 × sleep 0.25 = 32 ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  128.times do |i|
    sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.4
    sleep 0.25
  end
end
