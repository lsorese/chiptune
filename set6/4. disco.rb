# disco.rb — two rounds, each with 64 beats of disco breakdown (2 sections each)
# 240 BPM  |  B
#
# round 1: t=0 blast | t=1,2 disco (64 beats) | t=3 blast+glitch | t=4 nuclear
# round 2: t=5 blast | t=6,7 disco (64 beats) | t=8 blast+glitch | t=9 nuclear (louder)
#
# run_file "/Users/logan/Projects/chiptune/set6/4. disco.rb"

use_bpm 240

SONG_END = 10

GNOISE_GR  = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-dark-pink.wav"
GPERCS_GR  = [
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc2.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc4.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac",
]

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  osc_send "localhost", 4559, "/sp/disco/section", t
  sleep t == 0 ? 16 : 32
end

# ── Blast drums ───────────────────────────────────────────────────────────────
# t=1,2,6,7: disco breakdown; everything else: blast beat
live_loop :drums, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  round2 = t >= 5
  if [1, 2, 6, 7].include?(t)
    kick_amp = round2 ? 3.6 : 3.2
    sn_amp   = round2 ? 3.8 : 3.4
    8.times do
      sample :bd_haus, amp: kick_amp;             sleep 1
      sample :bd_haus, amp: kick_amp - 0.4;      sleep 0.5
      sample :bd_haus, amp: kick_amp - 0.4;      sleep 0.5
      sample :sn_dolf, amp: sn_amp, rate: 0.75;  sleep 2
    end
  else
    blast_amp = round2 ? 3.2 : 2.8
    128.times do |i|
      sample :bd_haus, amp: blast_amp
      sample :sn_dolf, amp: blast_amp - 0.5, rate: 0.90 if i.odd?
      sleep 0.25
    end
  end
end

# ── Bass ──────────────────────────────────────────────────────────────────────
# t=1,2,4,6,7,9: disco octave pump; else: rapid B1
live_loop :bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  round2 = t >= 5
  if [1, 2, 4, 6, 7, 9].include?(t)
    with_fx :distortion, distort: round2 ? 0.70 : 0.55 do
      use_synth :chipbass
      use_synth_defaults attack: 0, sustain: 0.35, release: 0.1,
                         amp: round2 ? 3.8 : 3.2
      8.times do
        play :b1;  sleep 0.5
        play :b2;  sleep 0.5
        play :fs2; sleep 0.5
        play :b2;  sleep 0.5
        play :b1;  sleep 0.5
        play :b2;  sleep 0.5
        play :e2;  sleep 0.5
        play :ds2; sleep 0.5
      end
    end
  else
    with_fx :distortion, distort: round2 ? 0.97 : 0.92 do
      with_fx :bitcrusher, bits: 4, sample_rate: 0.25 do
        use_synth :chipbass
        use_synth_defaults attack: 0, sustain: 0.1, release: 0.03,
                           amp: round2 ? 3.2 : 2.8
        128.times { play :b1; sleep 0.25 }
      end
    end
  end
end

# ── Lead — distorted saw power chords ─────────────────────────────────────────
# t=1,2,4,6,7,9: slow stabs; else: rapid riff
live_loop :lead, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  round2 = t >= 5
  with_fx :distortion, distort: 0.97 do
    with_fx :bitcrusher, bits: 4, sample_rate: 0.18 do
      use_synth :saw
      if [1, 2, 4, 6, 7, 9].include?(t)
        use_synth_defaults attack: 0.02, sustain: 1.7, release: 0.3,
                           amp: round2 ? 1.5 : 1.2, cutoff: 125
        8.times do
          play :b3; play :fs4; sleep 2
          play :e3; play :b3;  sleep 2
        end
      else
        use_synth_defaults attack: 0, sustain: 0.12, release: 0.04,
                           amp: round2 ? 1.3 : 1.0, cutoff: 128
        2.times do
          [[:b3, :fs4], [:b3, :fs4], [:e3, :b3], [:a3, :e4]].each do |r, f|
            4.times do
              play r; play f; sleep 0.5
              play r; play f; sleep 0.25
              play r; play f; sleep 0.25
            end
          end
        end
      end
    end
  end
end

# ── Noise wall ────────────────────────────────────────────────────────────────
live_loop :noise_wall, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.99 do
    with_fx :bitcrusher, bits: 3, sample_rate: 0.12 do
      use_synth :noise
      play :a3, sustain: 30, release: 2,
                amp: t >= 5 ? 0.7 : 0.5,
                cutoff: ([1, 2, 6, 7].include?(t) ? 78 : 108)
    end
  end
  sleep 32
end

# ── Glitch layer ──────────────────────────────────────────────────────────────
# t=3,4: round 1; t=8,9: round 2 (louder); nuclear sections (t=4,9) are loudest
live_loop :glitch, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  if [3, 4, 8, 9].include?(t)
    glitch_amp = [4, 9].include?(t) ? 1.5 : 1.0
    glitch_amp *= 1.3 if t >= 8
    sample GNOISE_GR, amp: 0.4 * glitch_amp, attack: 0.5, release: 4.0
    64.times do
      sample GPERCS_GR.choose, amp: rrand(0.6, glitch_amp * 1.2), rate: rrand(0.4, 2.2) if one_in(2)
      sleep 0.5
    end
  else
    sleep 32
  end
end
