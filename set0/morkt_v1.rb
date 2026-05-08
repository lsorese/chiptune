# morkt.rb
# Inspired by: GO! with fourteen o - "Mörkt" (Track 7)
# 108 BPM  |  F minor  |  Fm – Db – C – Bbm
#
# Slowest track. Heavy, sparse, minimal. Half-note bass, sparse drums.
# Open style — no synth melody, space for guitar/vocals on top.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/morkt_v1.rb"

use_bpm 108

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Ascending arp sweeps (both choruses) ─────────────────────────────────────
# 2 passes × 4 chords × 8 notes × 0.5 = 32 beats ✓
ARP_SWEEPS = [
  [:f4,  :ab4, :c5, :f5,  :ab5, :c6,  :f6,  :c6 ],  # Fm
  [:db4, :f4,  :ab4,:db5, :f5,  :ab5, :db6, :ab5],   # Db
  [:c4,  :e4,  :g4, :c5,  :e5,  :g5,  :c6,  :g5 ],   # C major
  [:bb3, :db4, :f4, :bb4, :db5, :f5,  :bb5, :f5 ],   # Bbm
]

live_loop :sweep_arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 7, sample_rate: 0.45 do
      with_fx :echo, phase: 0.5, decay: 1.5, mix: 0.18 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.1, release: 0.08,
                           amp: 0.4, pulse_width: 0.15, cutoff: 90
        2.times do
          ARP_SWEEPS.each do |chord|
            chord.each { |n| play n; sleep 0.5 }
          end
        end
      end
    end
  else
    sleep 32
  end
end

# ── Chip bass (half-note sweep, 32 beats = 2× 4-chord × 4-step pattern) ──────
# 2 × 4 chords × 4 beats = 32 ✓
BASS_ROOTS    = [:f2,  :db2, :c2,  :bb1]
BASS_ROOTS_UP = [:f3,  :db3, :c3,  :bb2]
BASS_FIFTHS   = [:c3,  :ab2, :g2,  :f2 ]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = [1, 3].include?(sec) ? 2.2 : 1.8

  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.5, release: 0.15, amp: bass_amp
    2.times do
      BASS_ROOTS.each_with_index do |root, i|
        play root;              sleep 1
        play BASS_FIFTHS[i];    sleep 1
        play BASS_ROOTS_UP[i];  sleep 1
        play BASS_FIFTHS[i];    sleep 1
      end
    end
  end
end

# ── Kick (32 beats = 8× 4-beat bar, single hits on 1+3) ──────────────────────
# 8 × (sleep 2 + sleep 2) = 32 ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sample :bd_haus, amp: 2.2; sleep 2   # beat 1
    sample :bd_haus, amp: 2.0; sleep 2   # beat 3
  end
end

# ── Snare (32 beats = 8× 4-beat bar, heavy 2+4) ──────────────────────────────
# 8 × (sleep 1 + sample + sleep 2 + sample + sleep 1) = 8 × 4 = 32 ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 1
    sample :sn_dolf, amp: 2.3, rate: 0.85
    sleep 2
    sample :sn_dolf, amp: 2.5, rate: 0.82
    sleep 1
  end
end

# ── Hats (32 beats, very sparse — quarter notes only, low amp) ────────────────
# 32 × sleep 1 = 32 ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  32.times do |i|
    sample :hat_snap, amp: (i.even? ? 0.7 : 0.4), rate: 0.88
    sleep 1
  end
end
