# fracture.rb
# 158 BPM  |  C# minor  |  C#m – A – E – B
#
# sec 0 — verse:        chipbass walk, ska hats, light kick
# sec 1 — chorus:       ascending arp, double kick, 16th hats
# sec 2 — breakdown:    whole-note bass, kick on 1 only, snare on 3 only, no hats
# sec 3 — final chorus: ascending arp + descending stabs together, blast kick
#
# run_file "/Users/logan/Projects/chiptune/set3/fracture.rb"

use_bpm 158

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Ascending arp (chorus + final chorus) ─────────────────────────────────────
# 2 passes × 4 chords × 8 notes × sleep 0.5 = 32 beats ✓
ARP_UP = [
  [:cs5, :e5,  :gs5, :cs6, :gs5, :e5,  :cs5, :gs4],   # C#m
  [:a4,  :cs5, :e5,  :a5,  :e5,  :cs5, :a4,  :e4 ],   # A
  [:e4,  :gs4, :b4,  :e5,  :b4,  :gs4, :e4,  :b3 ],   # E
  [:b4,  :ds5, :fs5, :b5,  :fs5, :ds5, :b4,  :fs4],   # B
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
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

# ── Descending stabs (final chorus only) ──────────────────────────────────────
# 2 passes × 4 chords × (8×0.25 + sleep 2) = 2×4×4 = 32 beats ✓
STABS_DOWN = [
  [:cs6, :gs5, :e5,  :cs5, :gs4, :e4,  :gs4, :cs5],   # C#m
  [:a5,  :e5,  :cs5, :a4,  :e4,  :cs4, :e4,  :a4 ],   # A
  [:e5,  :b4,  :gs4, :e4,  :b3,  :gs3, :b3,  :e4 ],   # E
  [:b5,  :fs5, :ds5, :b4,  :fs4, :ds4, :fs4, :b4 ],   # B
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 3
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
# sec 0,1,3: walk (2×4×8×0.5 = 32) ✓
# sec 2:     whole notes (2×4×sleep4 = 32) ✓
BASS_ROOTS = [:cs2, :a1, :e2, :b1]
BASS_WALK  = [:e2,  :cs2, :gs2, :ds2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    if sec == 2
      use_synth_defaults attack: 0, sustain: 3.0, release: 0.5, amp: 2.5
      2.times do
        BASS_ROOTS.each { |r| play r; sleep 4 }
      end
    else
      bass_amp = [1, 3].include?(sec) ? 2.2 : 1.6
      use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: bass_amp
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
# sec 2:     beat 3 only — half-time feel (8×4 = 32) ✓
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
