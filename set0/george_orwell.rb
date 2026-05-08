# george_orwell.rb
# Inspired by: GO! with fourteen o - "George Orwell's Collection Of Hidden Cameras" (Track 6)
# 103 BPM  |  C minor  |  Cm – Ab – Eb – Bb
#
# Martial. Staccato bass on beats 1+3. March chord stabs on 2+4 (chorus). 16th hats.
# Open style — no synth melody, space for guitar/vocals.
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

# ── March chord stabs (chorus: beats 2+4) ─────────────────────────────────────
# 2 passes × 4 chords × (sleep1 + stab + sleep2 + stab + sleep1) = 2×4×4 = 32 ✓
MARCH_STABS = [
  [:c4,  :eb4, :g4 ],   # Cm
  [:ab3, :c4,  :eb4],   # Ab
  [:eb3, :g3,  :bb3],   # Eb
  [:bb3, :d4,  :f4 ],   # Bb
]

live_loop :march_stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 7, sample_rate: 0.5 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.2, release: 0.1,
                         amp: 0.65, pulse_width: 0.3, cutoff: 85
      2.times do
        MARCH_STABS.each do |chord|
          sleep 1
          chord.each { |n| play n }
          sleep 2
          chord.each { |n| play n }
          sleep 1
        end
      end
    end
  else
    sleep 32
  end
end

# ── Staccato chip bass (beats 1+3 only, 32 beats) ─────────────────────────────
# 2 passes × 4 chords × (sleep1 + sleep1 + sleep1 + sleep1) = 2×4×4 = 32 ✓
BASS_ROOTS = [:c2,  :ab1, :eb2, :bb1]
BASS_FIFTH = [:g2,  :eb2, :bb2, :f2 ]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = [1, 3].include?(sec) ? 2.2 : 1.8
  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.12, release: 0.05, amp: bass_amp
    2.times do
      BASS_ROOTS.zip(BASS_FIFTH).each do |root, fifth|
        play root;  sleep 1
        sleep 1
        play fifth; sleep 1
        sleep 1
      end
    end
  end
end

# ── Kick (4-on-the-floor, 32 beats) ───────────────────────────────────────────
# 32 × sleep 1 = 32 ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  32.times do
    sample :bd_haus, amp: 2.2
    sleep 1
  end
end

# ── Snare (beats 2+4, 32 beats) ───────────────────────────────────────────────
# 8 × (sleep1 + sample + sleep2 + sample + sleep1) = 32 ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 1
    sample :sn_dolf, amp: 2.0, rate: 0.95
    sleep 2
    sample :sn_dolf, amp: 2.2, rate: 0.92
    sleep 1
  end
end

# ── Hats (16th notes, 32 beats) ───────────────────────────────────────────────
# 128 × sleep 0.25 = 32 ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  128.times do |i|
    sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.5), rate: 1.4
    sleep 0.25
  end
end
