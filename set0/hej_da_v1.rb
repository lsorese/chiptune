# hej_da.rb
# Inspired by: GO! with fourteen o - "Hej Då, Nu Dör Jag"
# 144 BPM  |  Eb major  |  Eb – Bb – Cm – Ab
#
# Album opener. Bass + drums only — bright, energetic groove.
# No melody, no arp stabs. Single pattern throughout (no sec distinction).
# SONG_END = 4  (~55 seconds)
#
# run_file "/Users/logan/Projects/chiptune/hej_da_v1.rb"

use_bpm 144

SONG_END = 4

# ── Conductor ─────────────────────────────────────────────────────────────────
# t=0: 16-beat silent intro. Drums miss this and arrive at t=1.
# t=1..4: normal 32-beat sections.
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Bass (32 beats = 2× 4-chord × 8-step pattern) ────────────────────────────
# Eb major: Eb – Bb – Cm – Ab  (I–V–vi–IV)
BASS_ROOTS = [:eb2, :bb2, :c2,  :ab2]
BASS_WALK  = [:g2,  :f2,  :g2,  :eb2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END

  with_fx :distortion, distort: 0.5 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: 1.8
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

# ── Kick  (32 beats = 8× 4-beat bar) ─────────────────────────────────────────
# Same pattern for all sections — energetic opener groove.
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sample :bd_haus, amp: 2.0; sleep 1    # beat 1
    sleep 1                                # beat 2
    sample :bd_haus, amp: 1.8; sleep 0.5  # beat 3
    sample :bd_haus, amp: 1.4; sleep 0.5  # beat 3-and
    sleep 1                                # beat 4
  end
end

# ── Snare  (32 beats = 8× 4-beat bar) ────────────────────────────────────────
# Clean 2+4 only. sleep 1+sample+sleep 2+sample+sleep 1 = 4 beats.
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 1
    sample :sn_dolf, amp: 1.8, rate: 1.0
    sleep 2
    sample :sn_dolf, amp: 2.0, rate: 1.0
    sleep 1
  end
end

# ── Hats  (32 beats) ──────────────────────────────────────────────────────────
# 8th notes throughout. Beat 1 of each bar (every 8th step) accented.
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  64.times do |i|
    sample :hat_snap, amp: (i % 8 == 0) ? 1.0 : 0.6, rate: 1.1
    sleep 0.5
  end
end
