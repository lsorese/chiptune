# 6. coil.rb — set7: ACID TECHNO with a dub trapdoor
# 160 BPM → 128 BPM dub break → 172 BPM peak → 160 BPM outro
# F#m7 – Dmaj7 – Bm7 – C#7  →  Am7 – Fmaj7 – Dm7 – E7 at the peak
#
# Identity: the only :tb303 in the set, the only 4-on-the-floor house feel,
# and the only track built on 7th chords. Nothing else here uses open-hat
# offbeats or dub delay.
#
# t=0    groove   @160  F#m7 — 303 line, 4-on-floor, offbeat open hat
# t=1    stabs    @160  F#m7 — + dub chord stabs, clap on 2 & 4
# t=2    DUB      @128  F#m7 — half-time, 303 gone, delayed stabs, pad swell
# t=3,4  PEAK     @172  Am7  — modulation, cutoff cranked, driving 16ths
# t=5    groove   @160  F#m7 — back down, back home
# t=6    outro    @160  F#m7 — 303 alone, filter closing
#
# run_file "/Users/logan/Projects/chiptune/set7/6. coil.rb"

use_bpm 160

SONG_END = 7

NOISE  = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-pink.wav"
ASWELL = "/Users/logan/Projects/chiptune/samples/ambient/ambi_soft_buzz.flac"

def bpm_for(t)
  case t
  when 2    then 128
  when 3, 4 then 172
  else           160
  end
end

def sec_for(t)
  case t
  when 0    then :groove
  when 1    then :stabs
  when 2    then :dub
  when 3, 4 then :peak
  when 5    then :groove2
  else           :outro
  end
end

def peaking?(t)
  [3, 4].include?(t)
end

# ── 303 pattern ───────────────────────────────────────────────────────────────
ACID_PATTERN = [
  :n, :n, :h, :n, :r, :n, :h, :n,
  :f, :n, :h, :n, :n, :h, :n, :f
]

FS_ROOTS  = [:fs2, :d2,  :b1,  :cs2]
FS_FIFTHS = [:cs3, :a2,  :fs2, :gs2]
FS_STABS  = [[:fs4, :a4,  :cs5, :e5 ],   # F#m7
             [:d4,  :fs4, :a4,  :cs5],   # Dmaj7
             [:b3,  :d4,  :fs4, :a4 ],   # Bm7
             [:cs4, :f4,  :gs4, :b4 ]]   # C#7

AM_ROOTS  = [:a1,  :f1,  :d2,  :e2 ]
AM_FIFTHS = [:e2,  :c2,  :a2,  :b2 ]
AM_STABS  = [[:a3,  :c4,  :e4,  :g4 ],   # Am7
             [:f3,  :a3,  :c4,  :e4 ],   # Fmaj7
             [:d4,  :f4,  :a4,  :c5 ],   # Dm7
             [:e4,  :gs4, :b4,  :d5 ]]   # E7

def roots(t);  peaking?(t) ? AM_ROOTS  : FS_ROOTS  end
def fifths(t); peaking?(t) ? AM_FIFTHS : FS_FIFTHS end
def stabs(t);  peaking?(t) ? AM_STABS  : FS_STABS  end

def play_acid(root, fifth, cutoff_v, res_v, amp_v)
  ACID_PATTERN.each do |step|
    case step
    when :n then play root,      cutoff: cutoff_v, res: res_v, amp: amp_v
    when :h then play root + 12, cutoff: cutoff_v, res: res_v, amp: amp_v * 1.1
    when :f then play fifth,     cutoff: cutoff_v, res: res_v, amp: amp_v
    end
    sleep 0.25
  end
end

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  use_bpm bpm_for(t.zero? ? 0 : t - 1)
  osc_send "localhost", 4559, "/sp/coil/section", t
  sleep t.zero? ? 16 : 32
end

# ── Acid bass ─────────────────────────────────────────────────────────────────
live_loop :acid, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  if sec == :dub
    sleep 32
  else
    cutoff_v = case sec
               when :groove          then 80
               when :stabs, :groove2 then 95
               when :outro           then 70
               else                       118
               end
    res_v = sec == :peak ? 0.93 : 0.85
    amp_v = sec == :peak ? 1.4  : 1.0
    with_fx :distortion, distort: sec == :peak ? 0.55 : 0.35 do
      use_synth :tb303
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.04, wave: 0
      2.times do
        roots(t).zip(fifths(t)).each do |root, fifth|
          play_acid(root, fifth, cutoff_v, res_v, amp_v)
        end
      end
    end
  end
end

# ── Dub chord stabs ───────────────────────────────────────────────────────────
live_loop :chord_stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  case sec
  when :dub
    # half-time, drenched — the stabs become the whole track
    with_fx :echo, phase: 0.75, decay: 8, mix: 0.55 do
      with_fx :reverb, mix: 0.6, room: 0.85 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.08, release: 0.4,
                           pulse_width: 0.3, cutoff: 95, amp: 0.6
        2.times do
          stabs(t).each do |chord|
            sleep 1
            play chord
            sleep 1
            play chord.map { |n| note(n) + 12 }, amp: 0.35
            sleep 2
          end
        end
      end
    end

  when :stabs, :peak
    with_fx :reverb, mix: 0.4, room: 0.7 do
      with_fx :hpf, cutoff: 70 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.05, release: 0.15,
                           pulse_width: 0.3, cutoff: 100,
                           amp: sec == :peak ? 0.65 : 0.5
        2.times do
          stabs(t).each do |chord|
            4.times { sleep 0.5; play chord; sleep 0.5 }
          end
        end
      end
    end

  else
    sleep 32
  end
end

# ── Kick ──────────────────────────────────────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :dub
    8.times { sample :bd_haus, amp: 2.2; sleep 4 }
  when :outro
    16.times { sample :bd_haus, amp: 1.8; sleep 2 }
  when :peak
    32.times { sample :bd_haus, amp: 2.5; sleep 1 }
  else
    32.times { sample :bd_haus, amp: 2.0; sleep 1 }
  end
end

# ── Clap ──────────────────────────────────────────────────────────────────────
live_loop :clap, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :stabs, :peak, :groove2
    16.times do
      sleep 1
      sample :sn_zome, amp: sec_for(t) == :peak ? 2.0 : 1.6, rate: 0.95
      sleep 1
    end
  when :dub
    with_fx :echo, phase: 0.5, decay: 6, mix: 0.5 do
      8.times { sleep 2; sample :sn_zome, amp: 1.8, rate: 0.8; sleep 2 }
    end
  else
    sleep 32
  end
end

# ── Hats ──────────────────────────────────────────────────────────────────────
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :dub
    16.times { sleep 1; sample :drum_cymbal_pedal, amp: 0.4, rate: 1.1; sleep 1 }
  when :peak
    128.times { |i| sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.5; sleep 0.25 }
  when :outro
    32.times { sleep 0.5; sample :drum_cymbal_pedal, amp: 0.35, rate: 1.4; sleep 0.5 }
  else
    32.times { sleep 0.5; sample :drum_cymbal_pedal, amp: 0.5, rate: 1.4; sleep 0.5 }
  end
end

# ── Texture ───────────────────────────────────────────────────────────────────
live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :dub
    sample ASWELL, amp: 0.45, attack: 3.0, release: 6.0
    sample NOISE,  amp: 0.25, rate: 0.6, attack: 6.0, release: 8.0
    use_synth :saw
    with_fx :reverb, mix: 0.5 do
      play :a3, attack: 24, sustain: 4, release: 4,
                cutoff_slide: 28, cutoff: 60, amp: 0.4
      control note: :a3, cutoff: 125
    end
    sleep 32
  when :peak
    sample NOISE, amp: 0.3, attack: 0.05, release: 1.5, finish: 0.15
    sleep 32
  when :outro
    sample ASWELL, amp: 0.3, rate: 0.7, attack: 2.0, release: 8.0
    sleep 32
  else
    sleep 32
  end
end
