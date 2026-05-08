# hollow.rb
# 155 BPM  |  D minor  |  Dm – Bb – F – C
#
# sec 0 — verse:        root-only 8th bass (monotone drive), ska hats
# sec 1 — chorus:       gallop bass + power chord stabs, 16th hats, double kick
# sec 2 — breakdown:    reverb-drenched chord stabs (long sustain), whole-note bass, no hats
# sec 3 — final chorus: gallop + stabs + blast kick
#
# run_file "/Users/logan/Projects/chiptune/set3/hollow.rb"

use_bpm 155

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Power chord stabs ─────────────────────────────────────────────────────────
# sec 1,3: sharp bitcrushed stabs (2×4×sleep4 = 32) ✓
# sec 2:   same chords, long reverb + sustain (2×4×sleep4 = 32) ✓
# sec 0:   silent (sleep 32) ✓
POWER_STABS = [
  [:d4,  :a4],   # Dm5
  [:bb3, :f4],   # Bb5
  [:f3,  :c4],   # F5
  [:c4,  :g4],   # C5
]

live_loop :chord_stabs, sync: :conductor do
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
  elsif sec == 2
    with_fx :reverb, room: 0.98, mix: 0.7 do
      use_synth :pulse
      use_synth_defaults attack: 0.1, sustain: 3.0, release: 0.8,
                         amp: 0.6, pulse_width: 0.4, cutoff: 70
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
# sec 0:   root-only 8ths (2×4×8×0.5 = 32) ✓
# sec 1,3: gallop — 2×4×4triplets×1beat = 32 ✓
# sec 2:   whole notes (2×4×sleep4 = 32) ✓
BASS_ROOTS  = [:d2, :bb1, :f2, :c2]
BASS_FIFTHS = [:a2, :f2,  :c3, :g2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    case sec
    when 0
      use_synth_defaults attack: 0, sustain: 0.15, release: 0.05, amp: 1.8
      2.times do
        BASS_ROOTS.each do |root|
          8.times { play root; sleep 0.5 }
        end
      end
    when 2
      use_synth_defaults attack: 0, sustain: 3.0, release: 0.5, amp: 2.5
      2.times do
        BASS_ROOTS.each { |r| play r; sleep 4 }
      end
    else
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.04, amp: 2.2
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
# sec 0:   4-on-floor light (32×sleep1 = 32) ✓
# sec 1:   double on 1+3 (8×4 = 32) ✓
# sec 2:   beat 1 only (8×sleep4 = 32) ✓
# sec 3:   blast beat (64×sleep0.5 = 32) ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 0
    32.times do
      sample :bd_haus, amp: 1.8; sleep 1
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
      sample :sn_dolf, amp: 1.8, rate: 1.0
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
live_loop :crash, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 2
    8.times do
      sample :drum_cymbal_open, amp: 0.8, finish: 0.5
      sleep 4
    end
  else
    sleep 32
  end
end
