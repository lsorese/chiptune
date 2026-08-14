# 2. edge.rb — set7: HALF-TIME CRUSHER
# 148 BPM → 100 BPM sludge → 168 BPM finish  |  Cm → Fm modulation
#
# Identity: bd_fat / sn_dub / hat_metal, detuned :dsaw riff played in fat
# two-note dyads (no arpeggio), :tri sub doubling. Sits on the beat rather than
# racing over it — the tempo is the instrument here.
#
# t=0     intro   @148  Cm — riff over half-time drums
# t=1,2   groove  @148  Cm — full kit, riff, sub bass
# t=3     SLUDGE  @100  Cm–Gb–Bb–Ab — tritone drop, everything crawls
# t=4     lift    @148  Fm — modulation, groove returns a fourth up
# t=5,6   finish  @168  Fm — fastest section, riff in octaves
#
# run_file "/Users/logan/Projects/chiptune/set7/2. edge.rb"

use_bpm 148

SONG_END = 7

def bpm_for(t)
  case t
  when 3    then 100
  when 5, 6 then 168
  else           148
  end
end

def sec_for(t)
  case t
  when 0    then :intro
  when 1, 2 then :groove
  when 3    then :sludge
  when 4    then :lift
  else           :finish
  end
end

# ── Progressions ──────────────────────────────────────────────────────────────
# Cm–Ab–Fm–G  →  Cm–Gb–Bb–Ab (tritone sludge)  →  Fm–Db–Bbm–C (a fourth up)
CM_ROOTS  = [:c2,  :ab1, :f2,  :g1 ]
CM_THIRDS = [:eb3, :c3,  :ab3, :b2 ]

SL_ROOTS  = [:c2,  :gb1, :bb1, :ab1]
SL_THIRDS = [:eb3, :bb2, :d3,  :c3 ]

FM_ROOTS  = [:f2,  :db2, :bb1, :c2 ]
FM_THIRDS = [:ab3, :f3,  :db3, :e3 ]

def roots(t)
  case sec_for(t)
  when :sludge         then SL_ROOTS
  when :lift, :finish  then FM_ROOTS
  else                      CM_ROOTS
  end
end

def thirds(t)
  case sec_for(t)
  when :sludge         then SL_THIRDS
  when :lift, :finish  then FM_THIRDS
  else                      CM_THIRDS
  end
end

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  use_bpm bpm_for(t.zero? ? 0 : t - 1)
  osc_send "localhost", 4559, "/sp/edge/section", t
  sleep t.zero? ? 16 : 32
end

# ── Riff — detuned dsaw dyads ─────────────────────────────────────────────────
live_loop :riff, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  with_fx :distortion, distort: sec == :sludge ? 0.9 : 0.72 do
    with_fx :lpf, cutoff: sec == :sludge ? 88 : 120 do
      use_synth :dsaw
      case sec
      when :intro
        use_synth_defaults attack: 0.01, sustain: 1.7, release: 0.3,
                           amp: 0.55, detune: 0.15, cutoff: 95
        2.times do
          thirds(t).each do |n|
            play n - 12; sleep 2
            play n;      sleep 2
          end
        end

      when :sludge
        # one enormous dyad per bar — let it rot
        use_synth_defaults attack: 0.03, sustain: 3.2, release: 1.2,
                           amp: 0.85, detune: 0.35, cutoff: 82
        2.times do
          roots(t).zip(thirds(t)).each do |r, th|
            play r + 12
            play th - 12
            sleep 4
          end
        end

      when :finish
        use_synth_defaults attack: 0, sustain: 0.22, release: 0.08,
                           amp: 0.8, detune: 0.2, cutoff: 125
        2.times do
          thirds(t).each do |n|
            [0, 0, -5, 0, 0, 3, 0, -5].each do |iv|
              play n + iv
              play n + iv + 12
              sleep 0.5
            end
          end
        end

      else # :groove / :lift
        use_synth_defaults attack: 0, sustain: 0.4, release: 0.12,
                           amp: 0.7, detune: 0.18, cutoff: 112
        2.times do
          thirds(t).each do |n|
            play n;     sleep 1
            play n - 5; sleep 0.5
            play n;     sleep 0.5
            play n - 7; sleep 1
            play n;     sleep 1
          end
        end
      end
    end
  end
end

# ── Sub bass — :tri, thick and low ────────────────────────────────────────────
live_loop :sub, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  with_fx :distortion, distort: 0.4 do
    use_synth :tri
    case sec
    when :sludge
      use_synth_defaults attack: 0.01, sustain: 3.4, release: 0.8, amp: 2.6, cutoff: 70
      2.times { roots(t).each { |r| play r - 12; sleep 4 } }

    when :intro
      use_synth_defaults attack: 0, sustain: 1.7, release: 0.3, amp: 2.0, cutoff: 78
      2.times { roots(t).each { |r| play r; sleep 2; play r; sleep 2 } }

    when :finish
      use_synth_defaults attack: 0, sustain: 0.18, release: 0.06, amp: 2.2, cutoff: 84
      2.times do
        roots(t).each do |r|
          8.times { |i| play(i % 4 == 3 ? r + 12 : r); sleep 0.5 }
        end
      end

    else
      use_synth_defaults attack: 0, sustain: 0.32, release: 0.1, amp: 2.1, cutoff: 80
      2.times do
        roots(t).each do |r|
          play r;      sleep 1
          play r;      sleep 0.5
          play r + 12; sleep 0.5
          play r;      sleep 1
          play r + 7;  sleep 1
        end
      end
    end
  end
end

# ── Drums — bd_fat / sn_dub / hat_metal ───────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :intro
    8.times do
      sample :bd_fat, amp: 2.4; sleep 1.5
      sample :bd_fat, amp: 1.8; sleep 0.5
      sleep 2
    end
  when :sludge
    # colossal half-time: beat 1 and the "and" of 3
    8.times do
      sample :bd_fat, amp: 3.0; sleep 2
      sample :bd_fat, amp: 2.4; sleep 0.5
      sleep 1.5
    end
  when :finish
    64.times { sample :bd_fat, amp: 2.2; sleep 0.5 }
  else
    32.times { |i| sample :bd_fat, amp: (i.even? ? 2.4 : 1.9); sleep 1 }
  end
end

live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :sludge
    # snare only on beat 3 of each bar — huge and slow
    8.times { sleep 2; sample :sn_dub, amp: 3.0, rate: 0.7; sleep 2 }
  when :intro
    8.times { sleep 2; sample :sn_dub, amp: 2.0, rate: 0.95; sleep 2 }
  when :finish
    8.times do
      sleep 1
      sample :sn_dub, amp: 2.4, rate: 1.05
      sleep 1.5
      sample :sn_dub, amp: 1.6, rate: 1.2
      sleep 0.5
      sample :sn_dub, amp: 2.5, rate: 1.0
      sleep 1
    end
  else
    8.times do
      sleep 1
      sample :sn_dub, amp: 2.2, rate: 1.0
      sleep 2
      sample :sn_dub, amp: 2.4, rate: 0.95
      sleep 1
    end
  end
end

live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :sludge
    # sparse metal hits, quarter notes only
    32.times { sample :hat_metal, amp: 0.7, rate: 0.8; sleep 1 }
  when :intro
    32.times { |i| sample(:hat_metal, amp: 0.5, rate: 1.0) if i.even?; sleep 1 }
  when :finish
    128.times { |i| sample :hat_metal, amp: (i % 4 == 0 ? 0.9 : 0.4), rate: 1.3; sleep 0.25 }
  else
    64.times { |i| sample :hat_metal, amp: (i.odd? ? 0.8 : 0.45), rate: 1.1; sleep 0.5 }
  end
end

# ── Texture — tempo-change markers ────────────────────────────────────────────
ADRONE_E = "/Users/logan/Projects/chiptune/samples/ambient/ambi_drone.flac"
GPERC_E  = "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac"

live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case t
  when 3
    sample ADRONE_E, amp: 0.35, rate: 0.7, attack: 1.0, release: 6.0
    sleep 32
  when 4
    sample :drum_cymbal_open, amp: 0.9, finish: 0.6
    sleep 32
  when 5, 6
    8.times { sample GPERC_E, amp: 0.4, rate: rrand(0.9, 1.3); sleep 4 }
  else
    sleep 32
  end
end
