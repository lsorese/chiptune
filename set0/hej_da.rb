# hej_da.rb
# Inspired by: GO! with fourteen o - "Hej Då, Nu Dör Jag" (Track 1)
# 144 BPM  |  Eb major  |  Eb – Bb – Cm – Ab
#
# Bright, poppy opener. Chord stabs on beat 1. Root-octave-fifth bass. Off-beat hats.
# Open style — no synth melody, space for guitar/vocals.
# SONG_END = 4
#
# run_file "/Users/logan/Projects/chiptune/hej_da.rb"

use_bpm 144

SONG_END = 4

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Chord stabs (beat 1 of each bar, every section) ──────────────────────────
# 2 passes × 4 chords × sleep 4 = 32 beats ✓
CHORD_STABS = [
  [:eb4, :g4,  :bb4],   # Eb
  [:bb3, :d4,  :f4 ],   # Bb
  [:c4,  :eb4, :g4 ],   # Cm
  [:ab3, :c4,  :eb4],   # Ab
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :bitcrusher, bits: 8, sample_rate: 0.6 do
    use_synth :pulse
    use_synth_defaults attack: 0, sustain: 0.35, release: 0.25,
                       amp: 0.7, pulse_width: 0.4, cutoff: 90
    2.times do
      CHORD_STABS.each do |chord|
        chord.each { |n| play n }
        sleep 4
      end
    end
  end
end

# ── Chip bass (root–octave–fifth bounce, 8th notes) ───────────────────────────
# 2 passes × 4 roots × 8 steps × 0.5 = 32 beats ✓
BASS_ROOTS = [:eb2, :bb1, :c2, :ab1]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.5 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.15, release: 0.06, amp: 1.8
    2.times do
      BASS_ROOTS.each do |root|
        play root;        sleep 0.5
        play root + 12;   sleep 0.5
        play root;        sleep 0.5
        play root + 7;    sleep 0.5
        play root;        sleep 0.5
        play root + 12;   sleep 0.5
        play root + 7;    sleep 0.5
        play root;        sleep 0.5
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
    sample :bd_haus, amp: 2.0
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
    sample :sn_dolf, amp: 1.8, rate: 1.1
    sleep 2
    sample :sn_dolf, amp: 2.0, rate: 1.05
    sleep 1
  end
end

# ── Hats (off-beat 8ths, ska style, 32 beats) ─────────────────────────────────
# 64 steps × sleep 0.5 = 32 ✓  (only odd steps hit)
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  64.times do |i|
    sample :hat_snap, amp: 1.0, rate: 1.2 if i.odd?
    sleep 0.5
  end
end
