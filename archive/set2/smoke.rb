# smoke.rb
# 154 BPM  |  G minor  |  Gm – F – Eb – D  (Andalusian descending)
#
# Chromatic flat-2 bass (Phrygian feel — root/b2 alternating 16ths).
# Tritone single-note stab in chorus (one note per chord, bits: 5 = brutal crush).
# Verse: snare 2+4. Chorus: snare on every beat.
# Cyber metal — space for screamed vocals.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/set2/smoke.rb"

use_bpm 154

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Tritone single-note stabs (chorus only) ───────────────────────────────────
# 2 passes × 4 chords × sleep 4 = 32 beats ✓
TRITONE_NOTES = [:db5, :b4, :a4, :ab4]   # tritones of G, F, Eb, D

live_loop :tritone_stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 5, sample_rate: 0.3 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.35, release: 0.2,
                         amp: 0.65, pulse_width: 0.2, cutoff: 100
      2.times do
        TRITONE_NOTES.each do |n|
          play n
          sleep 4
        end
      end
    end
  else
    sleep 32
  end
end

# ── Chromatic flat-2 bass (16th root/b2 alternation, 32 beats) ───────────────
# 2 passes × 4 chords × 8 pairs × (0.25 + 0.25) = 32 beats ✓
BASS_ROOTS = [:g2, :f2, :eb2, :d2]
BASS_CHROM = [:ab2, :gb2, :e2, :eb2]   # flat-2 of each root

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = [1, 3].include?(sec) ? 2.2 : 1.8
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.1, release: 0.04, amp: bass_amp
    2.times do
      BASS_ROOTS.zip(BASS_CHROM).each do |root, chrom|
        8.times do
          play root;  sleep 0.25
          play chrom; sleep 0.25
        end
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

# ── Snare (2+4 in verse; every beat in chorus, 32 beats) ─────────────────────
# Verse: 8 × (sleep1 + snare + sleep2 + snare + sleep1) = 32 ✓
# Chorus: 32 × (snare + sleep1) = 32 ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    32.times do
      sample :sn_dolf, amp: 2.0, rate: 0.95
      sleep 1
    end
  else
    8.times do
      sleep 1
      sample :sn_dolf, amp: 2.0, rate: 1.0
      sleep 2
      sample :sn_dolf, amp: 2.2, rate: 0.95
      sleep 1
    end
  end
end

# ── Hats (verse: off-beat 8ths; chorus: 16ths, 32 beats) ─────────────────────
# Verse: 64 × sleep 0.5 = 32 ✓  (odd steps only)
# Chorus: 128 × sleep 0.25 = 32 ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 0.8 : 0.4), rate: 1.3
      sleep 0.25
    end
  else
    64.times do |i|
      sample :hat_snap, amp: 0.9, rate: 1.0 if i.odd?
      sleep 0.5
    end
  end
end
