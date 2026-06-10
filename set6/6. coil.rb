# coil.rb — set6: +20% length via SONG_END 8→10 (verse reprise cools down after glitch escalation)
# 160 BPM  |  F# minor  |  F#m – D – B – C#
#
# sec 0,2 — verse:      arp w/ light ring mod + bitcrusher, 4-on-floor kick, ska hats
# sec 1   — chorus:     arp + stabs, 16th hats, glitch accent every 4 beats
# sec 2   — breakdown:  slow bass, crash, noise drone, chaotic glitch
# sec 3   — verse reprise: escalating glitch (t=6 sparse, t=7 dense)
# (t=8,9 wrap to sec 0 — calm verse coda after the glitch climax)
#
# run_file "/Users/logan/Projects/chiptune/set6/5. coil.rb"

use_bpm 160

SONG_END = 10

GLITCH  = "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac"
BUZZ    = "/Users/logan/Projects/chiptune/samples/ambient/ambi_soft_buzz.flac"
NOISE   = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-pink.wav"
GPERCS  = [
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc2.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc4.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac",
]

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  osc_send "localhost", 4559, "/sp/coil/section", t
  sleep t == 0 ? 16 : 32
end

# ── Ascending arp (verse + chorus + verse reprise) ─────────────────────────────
ARP_UP = [
  [:fs4, :a4,  :cs5, :fs5, :cs5, :a4,  :fs4, :cs4],
  [:d4,  :fs4, :a4,  :d5,  :a4,  :fs4, :d4,  :a3 ],
  [:b3,  :ds4, :fs4, :b4,  :fs4, :ds4, :b3,  :fs3],
  [:cs4, :f4,  :gs4, :cs5, :gs4, :f4,  :cs4, :gs3],
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [0, 1, 3].include?(sec)
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

# ── Descending stabs (chorus only) ────────────────────────────────────────────
STABS_DOWN = [
  [:fs5, :cs5, :a4,  :fs4, :cs4, :a3,  :cs4, :fs4],
  [:d5,  :a4,  :fs4, :d4,  :a3,  :fs3, :a3,  :d4 ],
  [:b5,  :fs5, :ds5, :b4,  :fs4, :ds4, :fs4, :b4 ],
  [:cs5, :gs4, :f4,  :cs4, :gs3, :f3,  :gs3, :cs4],
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 1
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
BASS_ROOTS  = [:fs2, :d2,  :b1,  :cs2]
BASS_FIFTHS = [:cs3, :a2,  :fs2, :gs2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    case sec
    when 0, 3
      use_synth_defaults attack: 0, sustain: 0.1, release: 0.04, amp: 1.7
      2.times do
        BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
          8.times do
            play root;  sleep 0.25
            play fifth; sleep 0.25
          end
        end
      end
    when 1
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
    when 2
      use_synth_defaults attack: 0, sustain: 3.0, release: 0.5, amp: 2.5
      2.times do
        BASS_ROOTS.each { |r| play r; sleep 4 }
      end
    end
  end
end

# ── Kick ──────────────────────────────────────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 0, 3
    32.times do
      sample :bd_haus, amp: 2.0; sleep 1
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
  elsif [0, 3].include?(sec)
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
  when 0, 3
    64.times do |i|
      sample :hat_snap, amp: 1.0, rate: 1.2 if i.odd?
      sleep 0.5
    end
  when 1
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.4
      sleep 0.25
    end
  when 2
    sleep 32
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

# ── Texture ───────────────────────────────────────────────────────────────────
live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 1
    8.times do
      sample GLITCH, amp: 0.4
      sleep 4
    end
  when 2
    sample BUZZ,  amp: 0.3,  attack: 3.0, release: 5.0
    sample NOISE, amp: 0.25, attack: 4.0, release: 6.0
    64.times do
      sample GLITCH,            amp: rrand(0.7, 1.1), rate: rrand(0.6, 1.5) if one_in(2)
      sample GPERCS.choose,     amp: rrand(0.6, 1.0), rate: rrand(0.5, 1.6) if one_in(3)
      sleep 0.5
    end
  when 3
    if t == 7
      16.times do
        sample GLITCH, amp: 0.45 if one_in(4)
        sleep 1
      end
      16.times do
        sample GLITCH,        amp: 0.55 if one_in(2)
        sample GPERCS.choose, amp: 0.45, rate: rrand(0.7, 1.4) if one_in(3)
        sleep 1
      end
    else
      32.times do
        sample GLITCH, amp: 0.38 if one_in(6)
        sleep 1
      end
    end
  else
    sleep 32
  end
end
