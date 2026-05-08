# civil_eyes.rb
# Inspired by: GO! with fourteen o - "Civil Eyes" (Track 2)
# 167 BPM  |  A minor  |  Am – F – Em – Dm
#
# Relentless. 16th-note root/fifth alternating bass. No arp. Constant 16ths. Just drive.
# Open style — no synth melody, space for guitar/vocals.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/civil_eyes.rb"

use_bpm 167

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Driving bass (16th-note root/fifth alternation, 32 beats) ─────────────────
# 2 passes × 4 chords × 8 pairs × (0.25 + 0.25) = 32 beats ✓
BASS_ROOTS  = [:a2, :f2, :e2, :d2]
BASS_FIFTHS = [:e3, :c3, :b2, :a2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.1, release: 0.04, amp: 2.0
    2.times do
      BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
        8.times do
          play root;  sleep 0.25
          play fifth; sleep 0.25
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

# ── Snare (beats 2+4, 32 beats) ───────────────────────────────────────────────
# 8 × (sleep1 + sample + sleep2 + sample + sleep1) = 32 ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 1
    sample :sn_dolf, amp: 2.0, rate: 1.0
    sleep 2
    sample :sn_dolf, amp: 2.2, rate: 0.95
    sleep 1
  end
end

# ── Hats (constant 16ths, downbeat accent, 32 beats) ─────────────────────────
# 128 × sleep 0.25 = 32 ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  128.times do |i|
    sample :hat_snap, amp: (i % 4 == 0 ? 1.0 : 0.5), rate: 1.3
    sleep 0.25
  end
end
