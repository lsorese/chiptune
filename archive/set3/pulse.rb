# pulse.rb
# 170 BPM  |  Bb minor  |  Bbm – Gb – Db – Ab
#
# sec 0 — verse:        16th root/fifth bass (driving), ska hats
# sec 1 — chorus:       descending stabs + 4-on-floor kick, 16th hats
# sec 2 — breakdown:    staccato bass on beats 1+3, crash, half-time snare, no hats
# sec 3 — final chorus: stabs + 16th bass + blast kick
#
# run_file "/Users/logan/Projects/chiptune/set3/pulse.rb"

use_bpm 170

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Descending stabs (chorus + final chorus) ──────────────────────────────────
# 2 passes × 4 chords × (8×0.25 + sleep 2) = 2×4×4 = 32 beats ✓
STABS_DOWN = [
  [:bb5, :f5,  :db5, :bb4, :f4,  :db4, :f4,  :bb4],   # Bbm
  [:gb5, :db5, :bb4, :gb4, :db4, :bb3, :db4, :gb4],   # Gb
  [:db5, :ab4, :f4,  :db4, :ab3, :f3,  :ab3, :db4],   # Db
  [:ab5, :eb5, :c5,  :ab4, :eb4, :c4,  :eb4, :ab4],   # Ab
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 6, sample_rate: 0.4 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.08, release: 0.06,
                         amp: 0.55, pulse_width: 0.15, cutoff: 100
      2.times do
        STABS_DOWN.each do |pattern|
          pattern.each { |n| play n; sleep 0.25 }
          sleep 2
        end
      end
    end
  else
    sleep 32
  end
end

# ── Chip bass ─────────────────────────────────────────────────────────────────
# sec 0,1,3: 16th root/fifth (2×4×8pairs×0.5 = 32) ✓
# sec 2:     staccato beats 1+3 only (2×4×4 = 32) ✓
BASS_ROOTS  = [:bb2, :gb2, :db2, :ab2]
BASS_FIFTHS = [:f3,  :db3, :ab2, :eb3]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    if sec == 2
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.05, amp: 2.2
      2.times do
        BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
          play root;  sleep 1
          sleep 1
          play fifth; sleep 1
          sleep 1
        end
      end
    else
      bass_amp = [1, 3].include?(sec) ? 2.0 : 1.8
      use_synth_defaults attack: 0, sustain: 0.1, release: 0.04, amp: bass_amp
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
end

# ── Kick ──────────────────────────────────────────────────────────────────────
# sec 0,1: 4-on-floor (32×sleep1 = 32) ✓
# sec 2:   beat 1 only (8×sleep4 = 32) ✓
# sec 3:   blast beat (64×sleep0.5 = 32) ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 2
    8.times do
      sample :bd_haus, amp: 2.5; sleep 4
    end
  when 3
    64.times do
      sample :bd_haus, amp: 2.0; sleep 0.5
    end
  else
    32.times do
      sample :bd_haus, amp: 2.2; sleep 1
    end
  end
end

# ── Snare ─────────────────────────────────────────────────────────────────────
# sec 0,1,3: 2+4 (8×4 = 32) ✓
# sec 2:     beat 3 only (8×4 = 32) ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 2
    8.times do
      sleep 2
      sample :sn_dolf, amp: 2.8, rate: 0.80
      sleep 2
    end
  elsif sec == 0
    8.times do
      sleep 1
      sample :sn_dolf, amp: 1.8, rate: 1.05
      sleep 2
      sample :sn_dolf, amp: 2.0, rate: 1.0
      sleep 1
    end
  else
    8.times do
      sleep 1
      sample :sn_dolf, amp: 2.4, rate: 0.88
      sleep 2
      sample :sn_dolf, amp: 2.6, rate: 0.85
      sleep 1
    end
  end
end

# ── Hats ──────────────────────────────────────────────────────────────────────
# sec 0: ska off-beat 8ths (64×0.5 = 32, odd only) ✓
# sec 2: silent (sleep 32) ✓
# sec 1,3: 16ths (128×0.25 = 32) ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 0
    64.times do |i|
      sample :hat_snap, amp: 1.0, rate: 1.2 if i.odd?
      sleep 0.5
    end
  when 2
    sleep 32
  else
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.4
      sleep 0.25
    end
  end
end

# ── Crash (breakdown only) ────────────────────────────────────────────────────
# 8×sleep4 = 32 ✓
live_loop :crash, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 2
    8.times do
      sample :drum_cymbal_open, amp: 0.8, finish: 0.4
      sleep 4
    end
  else
    sleep 32
  end
end
