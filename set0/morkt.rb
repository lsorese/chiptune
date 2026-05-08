# morkt.rb
# Inspired by: GO! with fourteen o - "Mörkt" (Track 7)
# 108 BPM  |  F minor  |  Fm – Db – C – Bbm
#
# Slow, heavy, mournful. Half-note bass. Descending arp in chorus. No hats.
# Kick only on beat 1. Snare only on beat 3.
# Open style — no synth melody, space for guitar/vocals.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/morkt.rb"

use_bpm 108

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Slow descending arp with reverb (chorus only) ────────────────────────────
# 2 passes × 4 chords × 4 notes × sleep 1 = 32 beats ✓
SLOW_ARP = [
  [:f4,  :eb4, :c4,  :ab3],   # Fm
  [:db4, :c4,  :ab3, :f3 ],   # Db
  [:c4,  :b3,  :g3,  :e3 ],   # C
  [:bb3, :ab3, :f3,  :db3],   # Bbm
]

live_loop :slow_arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :reverb, room: 0.95, mix: 0.5 do
      with_fx :echo, phase: 1.0, decay: 2.0, mix: 0.2 do
        use_synth :pulse
        use_synth_defaults attack: 0.05, sustain: 0.5, release: 0.3,
                           amp: 0.45, pulse_width: 0.2, cutoff: 75
        2.times do
          SLOW_ARP.each do |chord|
            chord.each { |n| play n; sleep 1 }
          end
        end
      end
    end
  else
    sleep 32
  end
end

# ── Chip bass (half-note root–fifth, 32 beats) ────────────────────────────────
# 2 passes × 4 chords × (sleep2 + sleep2) = 32 beats ✓
BASS_ROOTS  = [:f2,  :db2, :c2,  :bb1]
BASS_FIFTHS = [:c3,  :ab2, :g2,  :f2 ]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.8, release: 0.2, amp: 2.0
    2.times do
      BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
        play root;  sleep 2
        play fifth; sleep 2
      end
    end
  end
end

# ── Kick (beat 1 only, 32 beats) ──────────────────────────────────────────────
# 8 bars × sleep 4 = 32 ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sample :bd_haus, amp: 2.5
    sleep 4
  end
end

# ── Snare (beat 3 only, 32 beats) ─────────────────────────────────────────────
# 8 bars × (sleep2 + sample + sleep2) = 32 ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 2
    sample :sn_dolf, amp: 2.5, rate: 0.82
    sleep 2
  end
end
