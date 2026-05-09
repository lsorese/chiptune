# fault.rb
# 175 BPM  |  B minor  |  Bm – G – D – A
#
# t=0   — breakdown:    whole-note bass, beat 1 kick, snare on 3, crash, no hats
# t=1,2 — verse:        walk bass, 4-on-floor kick, ska hats, arp
# t=3,4 — chorus:       stabs + gallop bass, double kick, 16th hats
# t=5   — glitch breakdown: whole-note bass, crash, heavy glitch texture
# t=6   — final chorus:     arp + stabs together, blast kick (returns hard)
# t=7   — breakdown:    stripped close, mirrors the open
#
# run_file "/Users/logan/Projects/chiptune/set5/1. fault.rb"

use_bpm 175

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  osc_send "localhost", 4559, "/sp/fault/section", t
  sleep t == 0 ? 16 : 32
end

# ── Ascending arp (verse + final chorus) ──────────────────────────────────────
# 2 passes × 4 chords × 8 notes × sleep 0.5 = 32 beats ✓
ARP_UP = [
  [:b3,  :d4,  :fs4, :b4,  :fs4, :d4,  :b3,  :fs3],   # Bm
  [:g3,  :b3,  :d4,  :g4,  :d4,  :b3,  :g3,  :d3 ],   # G
  [:d4,  :fs4, :a4,  :d5,  :a4,  :fs4, :d4,  :a3 ],   # D
  [:a3,  :cs4, :e4,  :a4,  :e4,  :cs4, :a3,  :e3 ],   # A
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  if t.between?(1, 2) || t == 6
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
  [:b5,  :fs5, :d5,  :b4,  :fs4, :d4,  :fs4, :b4 ],   # Bm
  [:g5,  :d5,  :b4,  :g4,  :d4,  :b3,  :d4,  :g4 ],   # G
  [:d5,  :a4,  :fs4, :d4,  :a3,  :fs3, :a3,  :d4 ],   # D
  [:a5,  :e5,  :cs5, :a4,  :e4,  :cs4, :e4,  :a4 ],   # A
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  if t.between?(3, 4) || t == 6
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
# t=0,7: whole note (2×4×sleep4 = 32) ✓
# t=1,2: walk (2×4×8×0.5 = 32) ✓
# t=3..6: gallop (2×4×4×1 = 32) ✓
BASS_ROOTS  = [:b1,  :g2,  :d2,  :a2]
BASS_FIFTHS = [:fs2, :d3,  :a2,  :e3]
BASS_WALK   = [:d2,  :b2,  :fs2, :cs3]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    if t == 0 || t == 5 || t == 7
      use_synth_defaults attack: 0, sustain: 3.0, release: 0.5, amp: 2.5
      2.times do
        BASS_ROOTS.each { |r| play r; sleep 4 }
      end
    elsif t.between?(1, 2)
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
# t=0,5,7: beat 1 only (8×sleep4 = 32) ✓
# t=1,2:   4-on-floor (32×sleep1 = 32) ✓
# t=3,4:   double on 1+3 (8×4 = 32) ✓
# t=6:     blast beat (64×sleep0.5 = 32) ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  if t == 0 || t == 5 || t == 7
    8.times do
      sample :bd_haus, amp: 2.5; sleep 4
    end
  elsif t.between?(1, 2)
    32.times do
      sample :bd_haus, amp: 2.0; sleep 1
    end
  elsif t.between?(3, 4)
    8.times do
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
    end
  else
    64.times do
      sample :bd_haus, amp: 2.0; sleep 0.5
    end
  end
end

# ── Snare ─────────────────────────────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  if t == 0 || t == 5 || t == 7
    8.times do
      sleep 2
      sample :sn_dolf, amp: 2.8, rate: 0.80
      sleep 2
    end
  elsif t.between?(1, 2)
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
  if t == 0 || t == 5 || t == 7
    sleep 32
  elsif t.between?(1, 2)
    64.times do |i|
      sample :hat_snap, amp: 1.0, rate: 1.2 if i.odd?
      sleep 0.5
    end
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
  if t == 0 || t == 5 || t == 7
    8.times do
      sample :drum_cymbal_open, amp: 0.8, finish: 0.4
      sleep 4
    end
  else
    sleep 32
  end
end

# ── Texture ───────────────────────────────────────────────────────────────────
# t=0,7:  ambi_dark_woosh swell (opening/closing breakdowns)
# t=3,4,6: sparse glitch_perc2 accent every 4 beats
# t=5:    dense glitch chaos — every half-beat, multiple samples, wide pitch range
GPERC_F  = "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc2.flac"
ADARK_F  = "/Users/logan/Projects/chiptune/samples/ambient/ambi_dark_woosh.flac"
GNOISE_F = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-dark-pink.wav"
GPERCS_F = [
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc2.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc4.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac",
]

live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  if t == 0 || t == 7
    sample ADARK_F, amp: 0.3, attack: 2.0, release: 5.0
    sleep 32
  elsif t == 5
    sample ADARK_F, amp: 0.4,  attack: 1.0, release: 5.0
    sample GNOISE_F, amp: 0.22, attack: 2.0, release: 5.0
    64.times do
      sample GPERCS_F.choose, amp: rrand(0.8, 1.4), rate: rrand(0.5, 1.9) if one_in(2)
      sleep 0.5
    end
  elsif t.between?(3, 4) || t == 6
    8.times do
      sample GPERC_F, amp: 0.45, rate: rrand(0.9, 1.1)
      sleep 4
    end
  else
    sleep 32
  end
end
