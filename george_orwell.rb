# george_orwell.rb
# Inspired by: GO! with fourteen o - "George Orwell's Collection Of Hidden Cameras" (Track 6)
# 103 BPM  |  C minor  |  Cm – Ab – Eb – Bb
#
# vi-IV-I-V feel from Eb major. Open style — no synth melody, space for guitar/vocals.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/george_orwell.rb"

use_bpm 103

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Bitcrushed stabs (chorus only) ───────────────────────────────────────────
# 2 passes × 4 chords × (8×0.25 + sleep 2) = 2 × 4 × 4 = 32 beats ✓
STABS = [
  [:c6,  :g5,  :eb5, :c5,  :g4,  :eb4, :g4,  :c5 ],  # Cm
  [:ab5, :eb5, :c5,  :ab4, :eb4, :c4,  :eb4, :ab4],   # Ab
  [:eb5, :bb4, :g4,  :eb4, :bb3, :g3,  :bb3, :eb4],   # Eb
  [:bb5, :f5,  :d5,  :bb4, :f4,  :d4,  :f4,  :bb4],   # Bb
]

live_loop :scream_lead, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 6, sample_rate: 0.4 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.08, release: 0.06,
                         amp: 0.55, pulse_width: 0.15, cutoff: 100
      2.times do
        STABS.each do |pattern|
          pattern.each { |n| play n; sleep 0.25 }
          sleep 2
        end
      end
    end
  else
    sleep 32
  end
end

# ── Chip bass (32 beats = 2× 4-chord × 8-step pattern) ───────────────────────
# 2 × 4 chords × 8 × 0.5 = 32 ✓
BASS_ROOTS = [:c2,  :ab1, :eb2, :bb1]
BASS_WALK  = [:eb2, :c2,  :g2,  :d2 ]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = [1, 3].include?(sec) ? 2.0 : 1.5

  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: bass_amp
    2.times do
      BASS_ROOTS.zip(BASS_WALK).each do |root, walk|
        play root;      sleep 0.5
        play root;      sleep 0.5
        play walk;      sleep 0.5
        play root;      sleep 0.5
        play root + 12; sleep 0.5
        play root;      sleep 0.5
        play root + 12; sleep 0.5
        play walk;      sleep 0.5
      end
    end
  end
end

# ── Kick (32 beats = 8× 4-beat bar) ──────────────────────────────────────────
# Verse: 0.5+0.5+1+0.5+0.5+1 = 4 beats ✓
# Chorus: 0.5+0.5+1+0.25+0.25+0.5+1 = 4 beats ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  8.times do
    if [1, 3].include?(sec)
      sample :bd_haus, amp: 2.2; sleep 0.5
      sample :bd_haus, amp: 1.8; sleep 0.5
      sleep 1
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.6; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.5
      sleep 1
    else
      sample :bd_haus, amp: 2.0; sleep 0.5
      sample :bd_haus, amp: 1.5; sleep 0.5
      sleep 1
      sample :bd_haus, amp: 2.0; sleep 0.5
      sample :bd_haus, amp: 1.5; sleep 0.5
      sleep 1
    end
  end
end

# ── Snare (32 beats = 8× 4-beat bar, 2+4) ────────────────────────────────────
# sleep 1 + sample + sleep 2 + sample + sleep 1 = 4 beats ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  8.times do
    if [1, 3].include?(sec)
      sleep 1
      sample :sn_dolf, amp: 2.2, rate: 0.9
      sleep 2
      sample :sn_dolf, amp: 2.4, rate: 0.88
      sleep 1
    else
      sleep 1
      sample :sn_dolf, amp: 1.8, rate: 1.05
      sleep 2
      sample :sn_dolf, amp: 2.0, rate: 1.0
      sleep 1
    end
  end
end

# ── Hats (32 beats) ───────────────────────────────────────────────────────────
# Verse: ska — 8th notes, offbeats only (64 × 0.5 = 32, odd steps only) ✓
# Chorus: metal 16ths, open cymbal on downbeat (128 × 0.25 = 32) ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    128.times do |i|
      if i % 4 == 0
        sample :drum_cymbal_open, amp: 0.85, finish: 0.05
      else
        sample :hat_snap, amp: 0.6, rate: 1.5
      end
      sleep 0.25
    end
  else
    64.times do |i|
      sample :hat_snap, amp: 1.1, rate: 0.95 if i.odd?
      sleep 0.5
    end
  end
end

# ── Crash (32 beats, chorus only) ─────────────────────────────────────────────
# 8 × sleep 4 = 32 ✓
live_loop :crash, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  8.times do
    if [1, 3].include?(sec)
      sample :drum_cymbal_open, amp: 0.9, finish: 0.25
    end
    sleep 4
  end
end
