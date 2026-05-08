# killer_oh.rb
# Inspired by: GO! with fourteen o - "Killer Oh" (Track 8)
# 162 BPM  |  Bb minor  |  Bbm – Gb – Fm – Ebm
#
# Aggressive. Tritone-jumping bass. Burst arp up/down in chorus. Double kick every beat.
# Open style — no synth melody, space for guitar/vocals.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/killer_oh.rb"

use_bpm 162

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Burst arp — up sweep then down sweep per chord (chorus only) ──────────────
# 2 passes × 4 chords × (4×0.25 + sleep1 + 4×0.25 + sleep1) = 2×4×4 = 32 ✓
ARP_UP   = [[:bb4,:db5,:f5, :bb5], [:gb4,:bb4,:db5,:gb5], [:f4,:ab4,:c5,:f5 ], [:eb4,:gb4,:bb4,:eb5]]
ARP_DOWN = [[:f5, :db5,:bb4,:f4 ], [:db5,:bb4,:gb4,:db4], [:c5, :ab4,:f4,:c4], [:bb4,:gb4,:eb4,:bb3]]

live_loop :burst_arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 6, sample_rate: 0.35 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.05, release: 0.04,
                         amp: 0.6, pulse_width: 0.1, cutoff: 110
      2.times do
        ARP_UP.each_with_index do |up_notes, i|
          up_notes.each    { |n| play n; sleep 0.25 }
          sleep 1
          ARP_DOWN[i].each { |n| play n; sleep 0.25 }
          sleep 1
        end
      end
    end
  else
    sleep 32
  end
end

# ── Tritone-jumping chip bass (8th notes, 32 beats) ───────────────────────────
# 4 chords × 8 pairs × (sleep0.5 + sleep0.5) = 4×8×1 = 32 ✓
BASS_ROOTS  = [:bb2, :gb2, :f2, :eb2]
BASS_FLAT5S = [:e3,  :c3,  :b2, :a2 ]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.65 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.18, release: 0.06, amp: 2.2
    BASS_ROOTS.zip(BASS_FLAT5S).each do |root, flat5|
      8.times do
        play root;  sleep 0.5
        play flat5; sleep 0.5
      end
    end
  end
end

# ── Double kick (every beat, 32 beats) ────────────────────────────────────────
# 32 × (sleep0.25 + sleep0.75) = 32 ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  32.times do
    sample :bd_haus, amp: 2.3
    sleep 0.25
    sample :bd_haus, amp: 1.7
    sleep 0.75
  end
end

# ── Snare (beats 2+4, 32 beats) ───────────────────────────────────────────────
# 8 × (sleep1 + sample + sleep2 + sample + sleep1) = 32 ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 1
    sample :sn_dolf, amp: 2.3, rate: 0.88
    sleep 2
    sample :sn_dolf, amp: 2.5, rate: 0.85
    sleep 1
  end
end

# ── Hats (16th notes, 32 beats) ───────────────────────────────────────────────
# 128 × sleep 0.25 = 32 ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  128.times do |i|
    sample :hat_snap, amp: (i % 2 == 0 ? 0.9 : 0.5), rate: 1.5
    sleep 0.25
  end
end
