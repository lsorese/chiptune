# coil.rb — set6: rebuilt as acid techno to differentiate from wire
# 160 BPM  |  F# minor  |  F#m7 – Dmaj7 – Bm7 – C#7
#
# sec 0 — groove:   squelchy 303 bass line, 4-on-floor kick, off-beat open hat
# sec 1 — stabs:    + dub chord stabs on the offbeat, clap on 2 & 4
# sec 2 — break:    303 + kick drop out, pad swells, filter riser texture
# sec 3 — peak:     303 cutoff cranked, stabs, clap, driving 16th hats
# (t=8,9 wrap to sec 0/1 — groove + stabs cool-down)
#
# run_file "/Users/logan/Projects/chiptune/set6/6. coil.rb"

use_bpm 160

SONG_END = 10

NOISE   = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-pink.wav"
ASWELL  = "/Users/logan/Projects/chiptune/samples/ambient/ambi_soft_buzz.flac"

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  osc_send "localhost", 4559, "/sp/coil/section", t
  sleep t == 0 ? 16 : 32
end

# ── Acid bass (TB-303-style) ──────────────────────────────────────────────────
# 16-step pattern per chord (4 beats), 4 chords = 16 beats, x2 = 32 beats.
# n=root, h=root+12, f=fifth, rest=:r. Rough Roland 303 vibe.
ACID_PATTERN = [
  :n,  :n,  :h,  :n,  :r,  :n,  :h,  :n,
  :f,  :n,  :h,  :n,  :n,  :h,  :n,  :f
]

ACID_ROOTS  = [:fs2, :d2,  :b1,  :cs2]
ACID_FIFTHS = [:cs3, :a2,  :fs2, :gs2]

def play_acid(root, fifth, cutoff_v, res_v, amp_v)
  ACID_PATTERN.each do |step|
    case step
    when :n then play root,       cutoff: cutoff_v, res: res_v, amp: amp_v
    when :h then play root + 12,  cutoff: cutoff_v, res: res_v, amp: amp_v * 1.1
    when :f then play fifth,      cutoff: cutoff_v, res: res_v, amp: amp_v
    end
    sleep 0.25
  end
end

live_loop :acid, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 2
    sleep 32
  else
    cutoff_v = case sec
               when 0 then 80
               when 1 then 95
               when 3 then 115
               end
    res_v = sec == 3 ? 0.92 : 0.85
    amp_v = sec == 3 ? 1.4  : 1.0
    with_fx :distortion, distort: sec == 3 ? 0.55 : 0.35 do
      use_synth :tb303
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.04, wave: 0
      2.times do
        ACID_ROOTS.zip(ACID_FIFTHS).each do |root, fifth|
          play_acid(root, fifth, cutoff_v, res_v, amp_v)
        end
      end
    end
  end
end

# ── Dub chord stabs (sec 1, 3) ────────────────────────────────────────────────
# F#m7, Dmaj7, Bm7, C#7 voicings — short, snappy, on the "&" of every beat.
STAB_CHORDS = [
  [:fs4, :a4,  :cs5, :e5 ],   # F#m7
  [:d4,  :fs4, :a4,  :cs5],   # Dmaj7
  [:b3,  :d4,  :fs4, :a4 ],   # Bm7
  [:cs4, :f4,  :gs4, :b4 ],   # C#7
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :reverb, mix: 0.4, room: 0.7 do
      with_fx :hpf, cutoff: 70 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.05, release: 0.15,
                           pulse_width: 0.3, cutoff: 100,
                           amp: sec == 3 ? 0.65 : 0.5
        2.times do
          STAB_CHORDS.each do |chord|
            # 4 beats per chord — stabs on the "&" of 1, 2, 3, 4
            4.times do
              sleep 0.5
              play chord
              sleep 0.5
            end
          end
        end
      end
    end
  else
    sleep 32
  end
end

# ── Kick — 4-on-floor (drops in break) ────────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 2
    # break: only beat 1 of each bar, soft
    8.times do
      sample :bd_haus, amp: 1.6
      sleep 4
    end
  else
    32.times do
      sample :bd_haus, amp: sec == 3 ? 2.4 : 2.0
      sleep 1
    end
  end
end

# ── Clap on 2 & 4 (sec 1, 3) ──────────────────────────────────────────────────
live_loop :clap, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    16.times do
      sleep 1
      sample :sn_dolf, amp: sec == 3 ? 1.9 : 1.6, rate: 0.95
      sleep 1
    end
  else
    sleep 32
  end
end

# ── Hats — open offbeat (sec 0,1) / driving 16ths (sec 3) ─────────────────────
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 0, 1
    # open hat on the "&" of every beat — house feel
    32.times do
      sleep 0.5
      sample :drum_cymbal_pedal, amp: 0.5, rate: 1.4
      sleep 0.5
    end
  when 3
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.5
      sleep 0.25
    end
  when 2
    sleep 32
  end
end

# ── Pad / texture — break swell + filter riser ────────────────────────────────
live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 2
    sample ASWELL, amp: 0.4, attack: 4.0, release: 6.0
    sample NOISE,  amp: 0.25, rate: 0.6, attack: 8.0, release: 8.0
    # filter riser climbing toward sec 3
    use_synth :saw
    with_fx :reverb, mix: 0.5 do
      play :fs3, attack: 24, sustain: 4, release: 4,
                 cutoff_slide: 28, cutoff: 60, amp: 0.4
      control note: :fs3, cutoff: 125
    end
    sleep 32
  when 3
    # peak: occasional noise crash to mark bar 1 of each phrase
    sample NOISE, amp: 0.3, attack: 0.05, release: 1.5, finish: 0.15
    sleep 32
  else
    sleep 32
  end
end
