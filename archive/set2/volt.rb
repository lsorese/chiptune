# volt.rb
# 185 BPM  |  Bb minor  |  Bbm – Eb – Ab – Gb
#
# Fastest track. Machine-gun 8th-note root-only bass. Blast-beat kick (every 8th).
# Verse: snare 2+4. Chorus: snare on every beat (grinding).
# Cyber metal — space for screamed vocals.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/set2/volt.rb"

use_bpm 185

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Machine-gun bass (8th notes, root only, 32 beats) ─────────────────────────
# 2 passes × 4 chords × 8 × sleep 0.5 = 32 beats ✓
BASS_ROOTS = [:bb2, :eb2, :ab2, :gb2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.65 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.15, release: 0.04, amp: 2.2
    2.times do
      BASS_ROOTS.each do |root|
        8.times do
          play root; sleep 0.5
        end
      end
    end
  end
end

# ── Kick (every 8th note — blast beat, 32 beats) ──────────────────────────────
# 64 × sleep 0.5 = 32 ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  64.times do
    sample :bd_haus, amp: 2.0
    sleep 0.5
  end
end

# ── Snare (2+4 verse; every beat chorus, 32 beats) ────────────────────────────
# Verse: 8 × (sleep1 + snare + sleep2 + snare + sleep1) = 32 ✓
# Chorus: 32 × (snare + sleep1) = 32 ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    32.times do
      sample :sn_dolf, amp: 2.2, rate: 0.9
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

# ── Hats (constant 16ths, 32 beats) ───────────────────────────────────────────
# 128 × sleep 0.25 = 32 ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  128.times do |i|
    sample :hat_snap, amp: (i % 4 == 0 ? 0.8 : 0.35), rate: 1.5
    sleep 0.25
  end
end
