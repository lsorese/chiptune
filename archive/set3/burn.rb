# burn.rb
# 125 BPM  |  E minor  |  Em – C – Am – B  (harmonic minor — B major V chord)
#
# sec 0 — verse:        chipbass walk, light drums, ska hats
# sec 1 — chorus:       ascending arp, double kick, 16th hats
# sec 2 — breakdown:    tritone-jumping bass, crash every bar, snare on 3 only, no hats
# sec 3 — final chorus: arp + descending stabs together, double kick
#
# run_file "/Users/logan/Projects/chiptune/set3/burn.rb"

use_bpm 125

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
  [:e4,  :g4,  :b4,  :e5,  :b4,  :g4,  :e4,  :b3 ],   # Em
  [:c4,  :e4,  :g4,  :c5,  :g4,  :e4,  :c4,  :g3 ],   # C
  [:a3,  :c4,  :e4,  :a4,  :e4,  :c4,  :a3,  :e3 ],   # Am
  [:b3,  :ds4, :fs4, :b4,  :fs4, :ds4, :b3,  :fs3],   # B major (harmonic V)
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
# 2 passes × 4 chords × (8×0.25 + sleep 2) = 32 beats ✓
STABS_DOWN = [
  [:e6,  :b5,  :g5,  :e5,  :b4,  :g4,  :b4,  :e5 ],   # Em
  [:c6,  :g5,  :e5,  :c5,  :g4,  :e4,  :g4,  :c5 ],   # C
  [:a5,  :e5,  :c5,  :a4,  :e4,  :c4,  :e4,  :a4 ],   # Am
  [:b5,  :fs5, :ds5, :b4,  :fs4, :ds4, :fs4, :b4 ],   # B major
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
# sec 2:     tritone alternation 8ths (2×4×8×0.5 = 32) ✓
BASS_ROOTS    = [:e2,  :c2,  :a1,  :b1]
BASS_WALK     = [:g2,  :e2,  :c2,  :ds2]
BASS_TRITONES = [:bb2, :fs2, :eb2, :f2]    # tritones of E, C, A, B

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    if sec == 2
      use_synth_defaults attack: 0, sustain: 0.18, release: 0.06, amp: 2.4
      2.times do
        BASS_ROOTS.zip(BASS_TRITONES).each do |root, tri|
          8.times do
            play root; sleep 0.5
            play tri;  sleep 0.5
          end
        end
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
# sec 0:   beats 1+3 light (8×4 = 32) ✓
# sec 1,3: double on 1+3 (8×4 = 32) ✓
# sec 2:   beat 1 only (8×sleep4 = 32) ✓
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
  when 2
    8.times do
      sample :bd_haus, amp: 2.5; sleep 4
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
      sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.35
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
      sample :drum_cymbal_open, amp: 0.8, finish: 0.4
      sleep 4
    end
  else
    sleep 32
  end
end
