# wire.rb — set6: +20% length via SONG_END 8→10 (verse reprise after meltdown cool-down)
# 164 BPM  |  G# minor  |  G#m – E – B – F#
#
# sec 0,2 — verse:    walk bass, 4-on-floor kick, ska hats, arp w/ ring mod shimmer
# sec 1   — break:    blast beat kick, 16th hats, slow bass,
#                     stabs as rapid bursts w/ long gaps + heavy ring mod
# sec 3   — meltdown: arp + chaos stabs together, blast beat, 16th hats,
#                     ring mod cranked — everything at once
# (t=8,9 wrap to sec 0 — walk bass and ska hats as meltdown cool-down)
#
# run_file "/Users/logan/Projects/chiptune/set6/6. wire.rb"

use_bpm 164

SONG_END = 10

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  osc_send "localhost", 4559, "/sp/wire/section", t
  sleep t == 0 ? 16 : 32
end

# ── Ascending arp (verse + meltdown) ──────────────────────────────────────────
ARP_UP = [
  [:gs4, :b4,  :ds5, :gs5, :ds5, :b4,  :gs4, :ds4],   # G#m
  [:e4,  :gs4, :b4,  :e5,  :b4,  :gs4, :e4,  :b3 ],   # E
  [:b3,  :ds4, :fs4, :b4,  :fs4, :ds4, :b3,  :fs3],   # B
  [:fs4, :as4, :cs5, :fs5, :cs5, :as4, :fs4, :cs4],   # F#
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [0, 2, 3].include?(sec)
    ring_freq = sec == 3 ? 440 : 180
    ring_mix  = sec == 3 ? 0.65 : 0.28
    bits_val  = sec == 3 ? 5   : 7
    with_fx :ring_mod, freq: ring_freq, mix: ring_mix do
      with_fx :bitcrusher, bits: bits_val, sample_rate: 0.45 do
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

# ── Descending stabs ──────────────────────────────────────────────────────────
STABS_DOWN = [
  [:gs5, :ds5, :b4,  :gs4, :ds4, :b3,  :ds4, :gs4],   # G#m
  [:e5,  :b4,  :gs4, :e4,  :b3,  :gs3, :b3,  :e4 ],   # E
  [:b5,  :fs5, :ds5, :b4,  :fs4, :ds4, :fs4, :b4 ],   # B
  [:fs5, :cs5, :as4, :fs4, :cs4, :as3, :cs4, :fs4],   # F#
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if sec == 1
    with_fx :ring_mod, freq: 220, mix: 0.7 do
      with_fx :bitcrusher, bits: 4, sample_rate: 0.28 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.1, release: 0.04,
                           amp: 0.7, pulse_width: 0.1, cutoff: 115
        2.times do
          STABS_DOWN.each do |pat|
            pat[0..3].each { |n| play n; sleep 0.125 }
            sleep 0.5
            pat[4..7].each { |n| play n; sleep 0.125 }
            sleep 2.5
          end
        end
      end
    end
  elsif sec == 3
    with_fx :ring_mod, freq: 320, mix: 0.55 do
      with_fx :bitcrusher, bits: 5, sample_rate: 0.35 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.06, release: 0.04,
                           amp: 0.65, pulse_width: 0.12, cutoff: 115
        2.times do
          STABS_DOWN.each do |pat|
            pat.each { |n| play n; sleep 0.25 }
            sleep 2
          end
        end
      end
    end
  else
    sleep 32
  end
end

# ── Chip bass ─────────────────────────────────────────────────────────────────
BASS_ROOTS  = [:gs2, :e2,  :b1,  :fs2]
BASS_FIFTHS = [:ds3, :b2,  :fs2, :cs3]
BASS_WALK   = [:b2,  :gs2, :ds2, :as2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    case sec
    when 0, 2
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
    when 1
      use_synth_defaults attack: 0, sustain: 1.6, release: 0.3, amp: 2.2
      2.times do
        BASS_ROOTS.zip(BASS_WALK).each do |root, walk|
          play root; sleep 2
          play walk; sleep 2
        end
      end
    when 3
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.04, amp: 2.4
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
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 0, 2
    32.times do
      sample :bd_haus, amp: 2.0; sleep 1
    end
  when 1, 3
    64.times do
      sample :bd_haus, amp: 2.0; sleep 0.5
    end
  end
end

# ── Snare ─────────────────────────────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [0, 2].include?(sec)
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
  when 0, 2
    64.times do |i|
      sample :hat_snap, amp: 1.0, rate: 1.1 if i.odd?
      sleep 0.5
    end
  when 1, 3
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.4
      sleep 0.25
    end
  end
end

# ── Texture — glitch_perc5 meltdown accent + ambi_swoosh break ────────────────
GPERC_W = "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac"
ASWOOSH_W = "/Users/logan/Projects/chiptune/samples/ambient/ambi_swoosh.flac"

live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  case sec
  when 1
    sample ASWOOSH_W, amp: 0.3, attack: 2.0, release: 5.0
    sleep 32
  when 3
    8.times do
      sample GPERC_W, amp: 0.5, rate: rrand(0.8, 1.2)
      sleep 4
    end
  else
    sleep 32
  end
end
