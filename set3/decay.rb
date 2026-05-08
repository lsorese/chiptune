# decay.rb
# 142 BPM  |  G minor  |  Gm – Eb – Bb – F
#
# sec 0 — verse:        syncopated bass (AND-of-2, AND-of-4), off-beat hats
# sec 1 — chorus:       gallop bass + power chord stabs, 16th hats
# sec 2 — breakdown:    half-note bass, crash every bar, no hats, snare on 3 only
# sec 3 — final chorus: gallop + stabs + blast kick
#
# run_file "/Users/logan/Projects/chiptune/set3/decay.rb"

use_bpm 142

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Power chord stabs (chorus + final chorus) ─────────────────────────────────
# 2 passes × 4 chords × sleep 4 = 32 beats ✓
POWER_STABS = [
  [:g4,  :d5 ],   # Gm5
  [:eb4, :bb4],   # Eb5
  [:bb3, :f4 ],   # Bb5
  [:f3,  :c4 ],   # F5
]

live_loop :power_stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 8, sample_rate: 0.55 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.5, release: 0.2,
                         amp: 0.75, pulse_width: 0.3, cutoff: 88
      2.times do
        POWER_STABS.each do |chord|
          chord.each { |n| play n }
          sleep 4
        end
      end
    end
  else
    sleep 32
  end
end

# ── Chip bass ─────────────────────────────────────────────────────────────────
# sec 0: syncopated — root+sleep1, sleep0.5, fifth+sleep0.5, root+sleep1, sleep0.5, walk+sleep0.5
#        per chord: 1+0.5+0.5+1+0.5+0.5 = 4 beats → 2×4×4 = 32 ✓
# sec 1,3: gallop — 4×(root+0.5, root+0.25, fifth+0.25) per chord → 2×4×4 = 32 ✓
# sec 2: half notes — root+sleep2, fifth+sleep2 per chord → 2×4×4 = 32 ✓
BASS_ROOTS  = [:g2, :eb2, :bb1, :f2]
BASS_FIFTHS = [:d3, :bb2, :f2,  :c3]
BASS_WALK   = [:bb2, :g2, :d2,  :a2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = sec == 2 ? 2.2 : ([1, 3].include?(sec) ? 2.2 : 1.6)
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    case sec
    when 0
      use_synth_defaults attack: 0, sustain: 0.18, release: 0.06, amp: bass_amp
      2.times do
        BASS_ROOTS.zip(BASS_FIFTHS, BASS_WALK).each do |root, fifth, walk|
          play root;  sleep 1
          sleep 0.5
          play fifth; sleep 0.5
          play root;  sleep 1
          sleep 0.5
          play walk;  sleep 0.5
        end
      end
    when 2
      use_synth_defaults attack: 0, sustain: 0.9, release: 0.2, amp: bass_amp
      2.times do
        BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
          play root;  sleep 2
          play fifth; sleep 2
        end
      end
    else
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.04, amp: bass_amp
      2.times do
        BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
          4.times do
            play root;  sleep 0.5
            play root;  sleep 0.25
            play fifth; sleep 0.25
          end
        end
      end
    end
  end
end

# ── Kick ──────────────────────────────────────────────────────────────────────
# sec 0: beats 1+3 (8×4 = 32) ✓
# sec 1: double on 1+3 (8×4 = 32) ✓
# sec 2: beat 1 only (8×sleep4 = 32) ✓
# sec 3: blast beat (64×sleep0.5 = 32) ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 0
    8.times do
      sample :bd_haus, amp: 1.8; sleep 1
      sleep 1
      sample :bd_haus, amp: 1.6; sleep 1
      sleep 1
    end
  when 1
    8.times do
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
    end
  when 2
    8.times do
      sample :bd_haus, amp: 2.5; sleep 4
    end
  when 3
    64.times do
      sample :bd_haus, amp: 2.0; sleep 0.5
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
# sec 0: off-beat 8ths (64×0.5 = 32, odd only) ✓
# sec 2: silent (sleep 32) ✓
# sec 1,3: 16ths (128×0.25 = 32) ✓
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 0
    64.times do |i|
      sample :hat_snap, amp: 1.0, rate: 1.1 if i.odd?
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
# sec 2: crash every bar (8×sleep4 = 32) ✓
# else: silent (sleep 32) ✓
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
