# 3. void.rb — set7: DOOM DIRGE with a double-time surge
# 88 BPM dirge → 118 BPM body → 158 BPM surge → 88 BPM collapse
# Eb minor → Bb minor modulation
#
# Identity: :prophet pads and a :hollow lead over bd_boom / sn_zome / hat_bdu.
# Nothing here arpeggiates — it tolls. The surge is the only fast thing in it.
#
# t=0     dirge     @88   Ebm–B–Gb–Db  — pad + tolling bass, no hats
# t=1,2   body      @118  Ebm–B–Gb–Db  — kit enters, hollow lead
# t=3,4   SURGE     @158  Bbm–Gb–Db–Ab — modulation, blast kit, square lead
# t=5     collapse  @88   Ebm–B–Gb–Db  — back to the toll, ends on Ebm
#
# run_file "/Users/logan/Projects/chiptune/set7/3. void.rb"

use_bpm 88

SONG_END = 6

def bpm_for(t)
  case t
  when 0, 5 then 88
  when 3, 4 then 158
  else           118
  end
end

def sec_for(t)
  case t
  when 0    then :dirge
  when 1, 2 then :body
  when 3, 4 then :surge
  else           :collapse
  end
end

def surging?(t)
  sec_for(t) == :surge
end

# ── Progressions ──────────────────────────────────────────────────────────────
EB_ROOTS  = [:eb2, :b1,  :gb2, :db2]
EB_FIFTHS = [:bb2, :gb2, :db3, :ab2]
EB_PADS   = [[:eb3, :gb3, :bb3], [:b2, :ds3, :fs3], [:gb3, :bb3, :db4], [:db3, :f3, :ab3]]

BB_ROOTS  = [:bb1, :gb1, :db2, :ab1]
BB_FIFTHS = [:f2,  :db2, :ab2, :eb2]
BB_PADS   = [[:bb2, :db3, :f3], [:gb2, :bb2, :db3], [:db3, :f3, :ab3], [:ab2, :c3, :eb3]]

def roots(t);  surging?(t) ? BB_ROOTS  : EB_ROOTS  end
def fifths(t); surging?(t) ? BB_FIFTHS : EB_FIFTHS end
def pads(t);   surging?(t) ? BB_PADS   : EB_PADS   end

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  use_bpm bpm_for(t.zero? ? 0 : t - 1)
  osc_send "localhost", 4559, "/sp/void/section", t
  sleep t.zero? ? 16 : 32
end

# ── Pad — the harmonic bed, always present ────────────────────────────────────
live_loop :pad, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  with_fx :reverb, room: 0.85, mix: sec == :surge ? 0.25 : 0.55 do
    with_fx :lpf, cutoff: sec == :surge ? 105 : 82 do
      use_synth :prophet
      use_synth_defaults attack: sec == :surge ? 0.2 : 2.0,
                         sustain: sec == :surge ? 2.4 : 4.5,
                         release: sec == :surge ? 0.6 : 2.5,
                         amp: sec == :collapse ? 0.75 : 0.6,
                         cutoff: sec == :surge ? 100 : 78
      2.times do
        pads(t).each do |chord|
          chord.each { |n| play n }
          sleep 4
        end
      end
    end
  end
end

# ── Bass — :fm, thick and tolling ─────────────────────────────────────────────
live_loop :bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  with_fx :distortion, distort: sec == :surge ? 0.65 : 0.45 do
    use_synth :fm
    case sec
    when :dirge, :collapse
      use_synth_defaults attack: 0.02, sustain: 3.2, release: 0.8,
                         amp: 2.4, divisor: 1.0, depth: 1.6
      2.times { roots(t).each { |r| play r - 12; sleep 4 } }

    when :surge
      use_synth_defaults attack: 0, sustain: 0.14, release: 0.05,
                         amp: 2.0, divisor: 2.0, depth: 2.2
      2.times do
        roots(t).zip(fifths(t)).each do |r, f|
          4.times do
            play r;  sleep 0.5
            play r;  sleep 0.25
            play f;  sleep 0.25
          end
        end
      end

    else # :body
      use_synth_defaults attack: 0, sustain: 0.55, release: 0.15,
                         amp: 2.2, divisor: 1.0, depth: 1.8
      2.times do
        roots(t).each do |r|
          play r;      sleep 1
          play r;      sleep 1
          play r + 12; sleep 1
          play r + 7;  sleep 1
        end
      end
    end
  end
end

# ── Lead — :hollow in the body, :square in the surge ──────────────────────────
BODY_MEL  = [[:bb4, 4], [:gb4, 2], [:f4, 2], [:eb4, 4], [:db4, 4],
             [:gb4, 4], [:f4, 2], [:eb4, 2], [:db4, 4], [:bb3, 4]]
SURGE_MEL = [[:f5, 1], [:db5, 1], [:bb4, 2], [:f5, 1], [:ab5, 1], [:f5, 2],
             [:db5, 1], [:bb4, 1], [:ab4, 2], [:db5, 1], [:f5, 1], [:ab5, 2],
             [:ab5, 1], [:f5, 1], [:db5, 2], [:eb5, 1], [:f5, 1], [:ab5, 2],
             [:c5, 1], [:eb5, 1], [:ab5, 2], [:eb5, 1], [:c5, 1], [:ab4, 2]]

live_loop :lead, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :body
    with_fx :reverb, room: 0.6, mix: 0.3 do
      use_synth :hollow
      use_synth_defaults attack: 0.08, release: 0.4, amp: 0.65, cutoff: 92, noise: 0.5
      BODY_MEL.each { |n, d| play n, sustain: d - 0.2; sleep d }
    end

  when :surge
    with_fx :bitcrusher, bits: 6, sample_rate: 0.4 do
      use_synth :square
      use_synth_defaults attack: 0, sustain: 0.18, release: 0.08,
                         amp: 0.55, cutoff: 108
      oct = t == 4 ? 12 : 0
      SURGE_MEL.each { |n, d| play note(n) + oct; sleep d }
    end

  when :collapse
    with_fx :reverb, room: 0.9, mix: 0.5 do
      use_synth :hollow
      use_synth_defaults attack: 0.5, release: 2.0, amp: 0.55, cutoff: 80, noise: 0.6
      [:bb4, :gb4, :eb4, :bb3].each { |n| play n, sustain: 6.0; sleep 8 }
    end

  else
    sleep 32
  end
end

# ── Kick — bd_boom ────────────────────────────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :dirge
    8.times { sample :bd_boom, amp: 2.6, rate: 0.9; sleep 4 }
  when :collapse
    8.times do
      sample :bd_boom, amp: 2.6, rate: 0.85; sleep 3
      sample :bd_boom, amp: 1.6, rate: 0.85; sleep 1
    end
  when :surge
    64.times { sample :bd_boom, amp: 2.0, rate: 1.15; sleep 0.5 }
  else
    16.times do
      sample :bd_boom, amp: 2.2, rate: 1.0; sleep 1
      sleep 0.5
      sample :bd_boom, amp: 1.7, rate: 1.0; sleep 0.5
    end
  end
end

# ── Snare — sn_zome ───────────────────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :dirge
    sleep 32
  when :collapse
    8.times { sleep 2; sample :sn_zome, amp: 2.6, rate: 0.75; sleep 2 }
  when :surge
    8.times do
      sleep 1
      sample :sn_zome, amp: 2.2, rate: 1.05
      sleep 2
      sample :sn_zome, amp: 2.4, rate: 1.0
      sleep 1
    end
  else
    8.times { sleep 2; sample :sn_zome, amp: 2.2, rate: 0.95; sleep 2 }
  end
end

# ── Hats — hat_bdu ────────────────────────────────────────────────────────────
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :dirge, :collapse
    sleep 32
  when :surge
    128.times { |i| sample :hat_bdu, amp: (i % 4 == 0 ? 0.85 : 0.4), rate: 1.4; sleep 0.25 }
  else
    64.times { |i| sample(:hat_bdu, amp: 0.6, rate: 1.0) if i.odd?; sleep 0.5 }
  end
end

# ── Texture ───────────────────────────────────────────────────────────────────
ASAUNA_V = "/Users/logan/Projects/chiptune/samples/ambient/ambi_sauna.flac"
GPERC_V  = "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc4.flac"

live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :dirge
    sample ASAUNA_V, amp: 0.35, rate: 0.6, attack: 4.0, release: 8.0
    sleep 32
  when :collapse
    sample ASAUNA_V, amp: 0.4, rate: 0.5, attack: 2.0, release: 10.0
    4.times { sample :drum_cymbal_open, amp: 0.7, finish: 0.6; sleep 8 }
  when :surge
    8.times { sample GPERC_V, amp: 0.45, rate: rrand(0.9, 1.4); sleep 4 }
  else
    sleep 32
  end
end
