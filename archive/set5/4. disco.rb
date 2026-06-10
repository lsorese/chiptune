# 4. disco.rb
# 240 BPM  |  B  |  blast beats, power chords, noise wall, disco breakdown
# ~28s total: 4s sync gap + 3 sections × 32 beats
#
# t=0: full blast
# t=1: disco breakdown — half-time drums, disco octave-pump bass
# t=2: blast returns + dense glitch layer
#
# run_file "/Users/logan/Projects/chiptune/set5/4. disco.rb"

use_bpm 240

SONG_END = 3

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
# t=0,2: kick every 16th, snare on alternating 16ths (128×0.25 = 32) ✓
# t=1:   breakdown — heavy 4-beat pattern (8×4 = 32) ✓
live_loop :drums, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  if t == 1
    8.times do
      sample :bd_haus, amp: 3.2; sleep 1
      sample :bd_haus, amp: 2.8; sleep 0.5
      sample :bd_haus, amp: 2.8; sleep 0.5
      sample :sn_dolf, amp: 3.4, rate: 0.75; sleep 2
    end
  else
    128.times do |i|
      sample :bd_haus, amp: 2.8
      sample :sn_dolf, amp: 2.7, rate: 0.90 if i.odd?
      sleep 0.25
    end
  end
end

# ── Bass ──────────────────────────────────────────────────────────────────────
# t=0,2: B1 every 16th (128×0.25 = 32) ✓
# t=1:   disco octave pump — 8×(8×0.5) = 32 ✓
live_loop :bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  if t == 1
    with_fx :distortion, distort: 0.55 do
      use_synth :chipbass
      use_synth_defaults attack: 0, sustain: 0.35, release: 0.1, amp: 3.2
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
    with_fx :distortion, distort: 0.92 do
      with_fx :bitcrusher, bits: 4, sample_rate: 0.25 do
        use_synth :chipbass
        use_synth_defaults attack: 0, sustain: 0.1, release: 0.03, amp: 2.8
        128.times { play :b1; sleep 0.25 }
      end
    end
  end
end

# ── Lead — distorted saw power chords ─────────────────────────────────────────
# t=0,2: rapid Bm riff — root+fifth pairs (2×4 patterns×4 reps×sleep1 = 32) ✓
# t=1:   slow heavy stabs — two pairs per 4 beats (8×(sleep2+sleep2) = 32) ✓
live_loop :lead, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.97 do
    with_fx :bitcrusher, bits: 4, sample_rate: 0.18 do
      use_synth :saw
      if t == 1
        use_synth_defaults attack: 0.02, sustain: 1.7, release: 0.3,
                           amp: 1.2, cutoff: 125
        8.times do
          play :b3; play :fs4; sleep 2
          play :e3; play :b3;  sleep 2
        end
      else
        use_synth_defaults attack: 0, sustain: 0.12, release: 0.04,
                           amp: 1.0, cutoff: 128
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
# sustained bitcrushed noise throughout — cutoff drops in breakdown
live_loop :noise_wall, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.99 do
    with_fx :bitcrusher, bits: 3, sample_rate: 0.12 do
      use_synth :noise
      play :a3, sustain: 30, release: 2, amp: 0.5, cutoff: (t == 1 ? 78 : 108)
    end
  end
  sleep 32
end

# ── Glitch layer (final section only) ─────────────────────────────────────────
# dense random glitch hits every half-beat + noise burst (64×0.5 = 32) ✓
live_loop :glitch, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  if t == 2
    sample GNOISE_GR, amp: 0.4, attack: 0.5, release: 4.0
    64.times do
      sample GPERCS_GR.choose, amp: rrand(0.6, 1.2), rate: rrand(0.4, 2.2) if one_in(2)
      sleep 0.5
    end
  else
    sleep 32
  end
end
