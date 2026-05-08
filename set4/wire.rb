# wire.rb
# 164 BPM  |  G# minor  |  G#m – E – B – F#
#
# sec 0,2 — verse:   ascending arp, walk bass, 4-on-floor kick, ska hats
# sec 1,3 — chorus:  descending stabs, gallop bass, double kick, 16th hats
#
# run_file "/Users/logan/Projects/chiptune/set4/wire.rb"

use_bpm 164

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Ascending arp (verse) ──────────────────────────────────────────────────────
# 2 passes × 4 chords × 8 notes × sleep 0.5 = 32 beats ✓
ARP_UP = [
  [:gs4, :b4,  :ds5, :gs5, :ds5, :b4,  :gs4, :ds4],   # G#m
  [:e4,  :gs4, :b4,  :e5,  :b4,  :gs4, :e4,  :b3 ],   # E
  [:b3,  :ds4, :fs4, :b4,  :fs4, :ds4, :b3,  :fs3],   # B
  [:fs4, :as4, :cs5, :fs5, :cs5, :as4, :fs4, :cs4],   # F#
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [0, 2].include?(sec)
    with_fx :bitcrusher, bits: 7, sample_rate: 0.45 do
      with_fx :echo, phase: 0.5, decay: 1.5, mix: 0.18 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.1, release: 0.08,
                           amp: 0.4, pulse_width: 0.18, cutoff: 88
        2.times do
          ARP_UP.each do |chord|
            chord.each { |n| play n; sleep 0.5 }
          end
        end
      end
    end
  else
    sleep 32
  end
end

# ── Descending stabs (chorus) ─────────────────────────────────────────────────
# 2 passes × 4 chords × (8×0.25 + sleep 2) = 32 beats ✓
STABS_DOWN = [
  [:gs5, :ds5, :b4,  :gs4, :ds4, :b3,  :ds4, :gs4],   # G#m
  [:e5,  :b4,  :gs4, :e4,  :b3,  :gs3, :b3,  :e4 ],   # E
  [:b5,  :fs5, :ds5, :b4,  :fs4, :ds4, :fs4, :b4 ],   # B
  [:fs5, :cs5, :as4, :fs4, :cs4, :as3, :cs4, :fs4],   # F#
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
# verse (0,2): walk (2×4×8×0.5 = 32) ✓
# chorus (1,3): gallop (2×4×4×1 = 32) ✓
BASS_ROOTS  = [:gs2, :e2,  :b1,  :fs2]
BASS_FIFTHS = [:ds3, :b2,  :fs2, :cs3]
BASS_WALK   = [:b2,  :gs2, :ds2, :as2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    if [0, 2].include?(sec)
      use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: 1.6
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
# verse (0,2): 4-on-floor (32×sleep1 = 32) ✓
# chorus (1,3): double on 1+3 (8×4 = 32) ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [0, 2].include?(sec)
    32.times do
      sample :bd_haus, amp: 2.0; sleep 1
    end
  else
    8.times do
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
    end
  end
end

# ── Snare ─────────────────────────────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [0, 2].include?(sec)
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
  if [0, 2].include?(sec)
    64.times do |i|
      sample :hat_snap, amp: 1.0, rate: 1.1 if i.odd?
      sleep 0.5
    end
  else
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.4
      sleep 0.25
    end
  end
end
