# edge.rb
# 148 BPM  |  C minor  |  Cm – Ab – Fm – G
#
# sec 0 — verse:        arp, bouncy bass, 4-on-floor kick, ska hats
# sec 1 — breakdown:    whole-note bass, beat 1 kick, snare on 3, crash, no hats
# sec 2 — chorus:       stabs + gallop bass, double kick, 16th hats
# sec 3 — final chorus: arp + stabs together, blast kick
#
# run_file "/Users/logan/Projects/chiptune/set5/2. edge.rb"

use_bpm 148

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  osc_send "localhost", 4559, "/sp/edge/section", t
  sleep t == 0 ? 16 : 32
end

# ── Ascending arp (verse + final chorus) ──────────────────────────────────────
# 2 passes × 4 chords × 8 notes × sleep 0.5 = 32 beats ✓
ARP_UP = [
  [:c4,  :eb4, :g4,  :c5,  :g4,  :eb4, :c4,  :g3 ],   # Cm
  [:ab3, :c4,  :eb4, :ab4, :eb4, :c4,  :ab3, :eb3],   # Ab
  [:f3,  :ab3, :c4,  :f4,  :c4,  :ab3, :f3,  :c3 ],   # Fm
  [:g3,  :b3,  :d4,  :g4,  :d4,  :b3,  :g3,  :d3 ],   # G
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [0, 3].include?(sec)
    with_fx :bitcrusher, bits: 7, sample_rate: 0.45 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.1, release: 0.08,
                         amp: 0.4, pulse_width: 0.18, cutoff: 88
      2.times do
        ARP_UP.each do |chord|
          chord.each { |n| play n; sleep 0.5 }
        end
      end
    end
  else
    sleep 32
  end
end

# ── Descending stabs (chorus + final chorus) ──────────────────────────────────
# 2 passes × 4 chords × (8×0.25 + sleep 2) = 32 beats ✓
STABS_DOWN = [
  [:c5,  :g4,  :eb4, :c4,  :g3,  :eb3, :g3,  :c4 ],   # Cm
  [:ab4, :eb4, :c4,  :ab3, :eb3, :c3,  :eb3, :ab3],   # Ab
  [:f4,  :c4,  :ab3, :f3,  :c3,  :ab2, :c3,  :f3 ],   # Fm
  [:g4,  :d4,  :b3,  :g3,  :d3,  :b2,  :d3,  :g3 ],   # G
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [2, 3].include?(sec)
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
# sec 0: bouncy root/oct/fifth (2×4×4 = 32) ✓
# sec 1: whole note (2×4×sleep4 = 32) ✓
# sec 2,3: gallop (2×4×4×1 = 32) ✓
BASS_ROOTS  = [:c2,  :ab1, :f2,  :g2]
BASS_FIFTHS = [:g2,  :eb2, :c3,  :d3]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    case sec
    when 0
      use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: 1.8
      2.times do
        BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
          play root;      sleep 1
          play root + 12; sleep 1
          play fifth;     sleep 1
          play root + 12; sleep 1
        end
      end
    when 1
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
# sec 0: 4-on-floor (32×sleep1 = 32) ✓
# sec 1: beat 1 only (8×sleep4 = 32) ✓
# sec 2: double on 1+3 (8×4 = 32) ✓
# sec 3: blast beat (64×sleep0.5 = 32) ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 0
    32.times do
      sample :bd_haus, amp: 2.0; sleep 1
    end
  when 1
    8.times do
      sample :bd_haus, amp: 2.5; sleep 4
    end
  when 2
    8.times do
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
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
  if sec == 1
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
  when 1
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
  if sec == 1
    8.times do
      sample :drum_cymbal_open, amp: 0.8, finish: 0.4
      sleep 4
    end
  else
    sleep 32
  end
end

# ── Texture — glitch_perc3 chorus accent + ambi_drone breakdown ───────────────
GPERC_E = "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac"
ADRONE_E = "/Users/logan/Projects/chiptune/samples/ambient/ambi_drone.flac"

live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 1
    sample ADRONE_E, amp: 0.25, attack: 3.0, release: 5.0
    sleep 32
  when 2, 3
    8.times do
      sample GPERC_E, amp: 0.4, rate: rrand(0.85, 1.15)
      sleep 4
    end
  else
    sleep 32
  end
end
