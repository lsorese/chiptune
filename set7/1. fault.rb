# 1. fault.rb — set7: HARDCORE PUNK
# 175 BPM → 200 BPM gear shift  |  B minor → D minor modulation
#
# Identity: distorted saw power chords (no arpeggios), bd_haus/sn_dolf/hat_snap,
# straight-ahead punk drive that snaps a fifth faster and a minor third higher
# for the last third.
#
# t=0     break   @175  Bm — whole-note bass, crash, no hats
# t=1,2   verse   @175  Bm — 8th-note power chords, 4-on-floor
# t=3,4   chorus  @175  Bm — gallop power chords, double kick, 16th hats
# t=5     SHIFT   @200  Dm — chromatic riser, modulation lands
# t=6,7   final   @200  Dm — everything, blast kick
#
# run_file "/Users/logan/Projects/chiptune/set7/1. fault.rb"

use_bpm 175

SONG_END = 8

def bpm_for(t)
  t < 5 ? 175 : 200
end

def sec_for(t)
  case t
  when 0     then :break
  when 1, 2  then :verse
  when 3, 4  then :chorus
  when 5     then :shift
  else            :final
  end
end

# ── Progressions — Bm for the first half, Dm after the gear shift ─────────────
BM_ROOTS  = [:b1,  :g1,  :d2,  :a1 ]
BM_FIFTHS = [:fs2, :d2,  :a2,  :e2 ]
BM_WALK   = [:d2,  :b1,  :fs2, :cs2]
BM_LEAD   = [:b3,  :g3,  :d4,  :a3 ]

DM_ROOTS  = [:d2,  :bb1, :f2,  :c2 ]
DM_FIFTHS = [:a2,  :f2,  :c3,  :g2 ]
DM_WALK   = [:f2,  :d2,  :a2,  :e2 ]
DM_LEAD   = [:d4,  :bb3, :f4,  :c4 ]

def roots(t);  t < 5 ? BM_ROOTS  : DM_ROOTS  end
def fifths(t); t < 5 ? BM_FIFTHS : DM_FIFTHS end
def walks(t);  t < 5 ? BM_WALK   : DM_WALK   end
def leads(t);  t < 5 ? BM_LEAD   : DM_LEAD   end

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  use_bpm bpm_for(t.zero? ? 0 : t - 1)
  osc_send "localhost", 4559, "/sp/fault/section", t
  sleep t.zero? ? 16 : 32
end

# ── Lead — distorted saw power chords ─────────────────────────────────────────
live_loop :lead, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  with_fx :distortion, distort: sec == :final ? 0.92 : 0.85 do
    with_fx :bitcrusher, bits: 6, sample_rate: 0.35 do
      use_synth :saw
      case sec
      when :break
        use_synth_defaults attack: 0.01, sustain: 3.4, release: 0.6, amp: 0.7, cutoff: 96
        2.times do
          roots(t).zip(leads(t)).each do |_, l|
            play l; play l + 7
            sleep 4
          end
        end

      when :verse
        use_synth_defaults attack: 0, sustain: 0.32, release: 0.1, amp: 0.95, cutoff: 112
        2.times do
          leads(t).each do |l|
            8.times { play l; play l + 7; sleep 0.5 }
          end
        end

      when :shift
        # chromatic riser — B up to D, then the new key slams in
        use_synth_defaults attack: 0, sustain: 0.14, release: 0.05, amp: 1.0, cutoff: 118
        16.times do |i|
          n = note(:b2) + (i / 2)
          play n; play n + 7
          sleep 1
        end
        8.times do |i|
          n = note(:b3) + i * 0.5
          play n; play n + 7
          sleep 1
        end
        play :d3; play :a3; play :d4
        sleep 8

      else # :chorus / :final
        amp_v = sec == :final ? 1.25 : 1.05
        use_synth_defaults attack: 0, sustain: 0.13, release: 0.04, amp: amp_v, cutoff: 122
        2.times do
          leads(t).each do |l|
            4.times do
              play l;      play l + 7;      sleep 0.5
              play l;      play l + 7;      sleep 0.25
              play l + 12; play l + 19;     sleep 0.25
            end
          end
        end
      end
    end
  end
end

# ── Chip bass ─────────────────────────────────────────────────────────────────
live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    case sec
    when :break
      use_synth_defaults attack: 0, sustain: 3.0, release: 0.5, amp: 2.5
      2.times { roots(t).each { |r| play r; sleep 4 } }

    when :verse
      use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: 1.7
      2.times do
        roots(t).zip(walks(t)).each do |root, walk|
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

    when :shift
      # driving root 8ths climbing to the new tonic
      use_synth_defaults attack: 0, sustain: 0.16, release: 0.05, amp: 2.2
      16.times { play :b1; sleep 1 }
      16.times { |i| play note(:b1) + (i / 8); sleep 1 }

    else
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.04, amp: 2.3
      2.times do
        roots(t).zip(fifths(t)).each do |root, fifth|
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
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :break
    8.times { sample :bd_haus, amp: 2.5; sleep 4 }
  when :verse
    32.times { sample :bd_haus, amp: 2.0; sleep 1 }
  when :shift
    # accelerating roll into the modulation
    16.times { sample :bd_haus, amp: 2.0; sleep 1 }
    16.times { sample :bd_haus, amp: 2.1; sleep 0.5 }
    32.times { sample :bd_haus, amp: 2.3; sleep 0.25 }
  when :chorus
    8.times do
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
    end
  else
    64.times { sample :bd_haus, amp: 2.1; sleep 0.5 }
  end
end

# ── Snare ─────────────────────────────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :break
    8.times { sleep 2; sample :sn_dolf, amp: 2.8, rate: 0.80; sleep 2 }
  when :verse
    8.times do
      sleep 1
      sample :sn_dolf, amp: 1.8, rate: 1.05
      sleep 2
      sample :sn_dolf, amp: 2.0, rate: 1.0
      sleep 1
    end
  when :shift
    16.times { sleep 1; sample :sn_dolf, amp: 2.2, rate: 0.95; sleep 1 }
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
  use_bpm bpm_for(t)
  case sec_for(t)
  when :break
    sleep 32
  when :verse, :shift
    64.times { |i| sample(:hat_snap, amp: 1.0, rate: 1.2) if i.odd?; sleep 0.5 }
  else
    128.times { |i| sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.4; sleep 0.25 }
  end
end

# ── Crash ─────────────────────────────────────────────────────────────────────
live_loop :crash, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :break
    8.times { sample :drum_cymbal_open, amp: 0.8, finish: 0.4; sleep 4 }
  when :final
    4.times { sample :drum_cymbal_open, amp: 0.7, finish: 0.35; sleep 8 }
  when :shift
    sleep 30
    sample :drum_cymbal_open, amp: 1.1, finish: 0.9
    sleep 2
  else
    sleep 32
  end
end
