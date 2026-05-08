# void.rb
# 118 BPM  |  Eb minor  |  Ebm – Bb – Gb – Db
#
# sec 0 — verse I:      arp, root-only 8th bass, beats 1+3 kick, ska hats (minimal)
# sec 1 — verse II:     arp, bouncy root/oct/fifth bass, 4-on-floor kick, ska hats
# sec 2 — chorus:       stabs + gallop bass, double kick, 16th hats
# sec 3 — breakdown:    whole-note bass, beat 1 kick, snare on 3, crash  ← stripped ending
#
# run_file "/Users/logan/Projects/chiptune/set4/void.rb"

use_bpm 118

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Ascending arp (verse I + verse II) ────────────────────────────────────────
# 2 passes × 4 chords × 8 notes × sleep 0.5 = 32 beats ✓
ARP_UP = [
  [:eb4, :gb4, :bb4, :eb5, :bb4, :gb4, :eb4, :bb3],   # Ebm
  [:bb3, :d4,  :f4,  :bb4, :f4,  :d4,  :bb3, :f3 ],   # Bb
  [:gb3, :bb3, :db4, :gb4, :db4, :bb3, :gb3, :db3],   # Gb
  [:db4, :f4,  :ab4, :db5, :ab4, :f4,  :db4, :ab3],   # Db
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [0, 1].include?(sec)
    with_fx :bitcrusher, bits: 7, sample_rate: 0.45 do
      with_fx :echo, phase: 0.5, decay: 2.0, mix: 0.22 do
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
  [:eb5, :bb4, :gb4, :eb4, :bb3, :gb3, :bb3, :eb4],   # Ebm
  [:bb4, :f4,  :d4,  :bb3, :f3,  :d3,  :f3,  :bb3],   # Bb
  [:gb4, :db4, :bb3, :gb3, :db3, :bb2, :db3, :gb3],   # Gb
  [:db5, :ab4, :f4,  :db4, :ab3, :f3,  :ab3, :db4],   # Db
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 2
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
# sec 0: root-only 8ths (2×4×8×0.5 = 32) ✓
# sec 1: bouncy root/oct/fifth (2×4×4 = 32) ✓
# sec 2: gallop (2×4×4×1 = 32) ✓
# sec 3: whole note (2×4×sleep4 = 32) ✓
BASS_ROOTS  = [:eb2, :bb1, :gb2, :db2]
BASS_FIFTHS = [:bb2, :f2,  :db3, :ab2]

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
    when 1
      use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: 2.0
      2.times do
        BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
          play root;      sleep 1
          play root + 12; sleep 1
          play fifth;     sleep 1
          play root + 12; sleep 1
        end
      end
    when 2
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
    when 3
      use_synth_defaults attack: 0, sustain: 3.0, release: 0.5, amp: 2.5
      2.times do
        BASS_ROOTS.each { |r| play r; sleep 4 }
      end
    end
  end
end

# ── Kick ──────────────────────────────────────────────────────────────────────
# sec 0: beats 1+3 (8×4 = 32) ✓
# sec 1: 4-on-floor (32×sleep1 = 32) ✓
# sec 2: double on 1+3 (8×4 = 32) ✓
# sec 3: beat 1 only (8×sleep4 = 32) ✓
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
    32.times do
      sample :bd_haus, amp: 2.0; sleep 1
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
    8.times do
      sample :bd_haus, amp: 2.5; sleep 4
    end
  end
end

# ── Snare ─────────────────────────────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 3
    8.times do
      sleep 2
      sample :sn_dolf, amp: 2.8, rate: 0.80
      sleep 2
    end
  elsif [0, 1].include?(sec)
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
  when 0, 1
    64.times do |i|
      sample :hat_snap, amp: 1.0, rate: 1.1 if i.odd?
      sleep 0.5
    end
  when 2
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.35
      sleep 0.25
    end
  when 3
    sleep 32
  end
end

# ── Crash (breakdown ending only) ─────────────────────────────────────────────
live_loop :crash, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 3
    8.times do
      sample :drum_cymbal_open, amp: 0.8, finish: 0.5
      sleep 4
    end
  else
    sleep 32
  end
end
