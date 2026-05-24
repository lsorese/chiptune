# interlude_5.rb — "broken machine" (full song length, ~2.8 min)
# 162 BPM | F# | syncopated glitch drums + pulse wall
# first half: sparse broken pattern; second half: denser, louder, more glitch
#
# run_file "/Users/logan/Projects/chiptune/set6/interlude_5.rb"

use_bpm 162

# 14 × 4 × 16 × 0.5 = 448 beats at 162 BPM = 165.9s ✓
TOTAL_SECTIONS = 14
HALFWAY        = TOTAL_SECTIONS / 2

gpercs = [
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc2.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc4.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac",
]
noise_loop  = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-pink.wav"
ambi_swoosh = "/Users/logan/Projects/chiptune/samples/ambient/ambi_swoosh.flac"

# noise + swoosh — sustain covers full duration
in_thread do
  sample noise_loop,  amp: 0.50, attack: 3.0, sustain: 172.0, release: 3.0
  sample ambi_swoosh, amp: 0.28, attack: 5.0, sustain: 168.0, release: 5.0
end

# F# thick pulse wall — all voices held for full duration
in_thread do
  with_fx :bitcrusher, bits: 5, sample_rate: 0.28 do
    with_fx :distortion, distort: 0.80 do
      use_synth :pulse
      [[:fs1, 0.08, 0.0, 0.55], [:fs2, 0.12, -0.8, 0.48],
       [:fs2, 0.25, 0.7, 0.42], [:cs2, 0.20, 0.4, 0.36],
       [:a2,  0.22, -0.5, 0.30]].each do |pitch, pw, pan, amp|
        play pitch, sustain: 176.0, release: 6.0,
                    amp: amp, pan: pan, pulse_width: pw,
                    cutoff: 85, attack: rrand(0.2, 1.5)
      end
    end
  end
  sleep 448
end

# ring-mod shimmer — more frequent in second half
in_thread do
  with_fx :ring_mod, freq: 80, mix: 0.22 do
    TOTAL_SECTIONS.times do |s|
      mix_val = s >= HALFWAY ? 0.38 : 0.22
      sleep rrand(s >= HALFWAY ? 6 : 10, s >= HALFWAY ? 14 : 20)
      with_fx :bitcrusher, bits: 7, sample_rate: 0.4 do
        use_synth :pulse
        play :fs3, sustain: rrand(6.0, 14.0), release: 4.0,
                   amp: s >= HALFWAY ? 0.30 : 0.18,
                   pulse_width: 0.20, cutoff: 82
      end
    end
  end
end

# syncopated drum pattern
# first half: sparse, some steps skipped randomly
# second half: denser, louder, glitch on every step
kicks  = [1,0,0,1,0,1,1,0,1,0,0,0,1,1,0,0]
snares = [0,0,0,0,1,0,0,1,0,0,1,0,0,0,1,0]
hats   = [1,1,0,1,0,0,1,0,1,1,0,1,0,1,0,1]

in_thread do
  with_fx :distortion, distort: 0.5 do
    TOTAL_SECTIONS.times do |s|
      second_half = s >= HALFWAY
      k_amp  = second_half ? rrand(2.4, 3.0) : rrand(2.0, 2.6)
      sn_amp = second_half ? rrand(2.2, 2.8) : rrand(1.8, 2.4)
      h_amp  = second_half ? rrand(0.8, 1.2) : rrand(0.6, 1.0)
      g_prob = second_half ? 2 : 3   # one_in(2) vs one_in(3)

      4.times do
        16.times do |i|
          sample :bd_haus,  amp: k_amp                                          if kicks[i]  == 1
          sample :sn_dolf,  amp: sn_amp, rate: rrand(0.85, 1.05)               if snares[i] == 1
          sample :hat_snap, amp: h_amp,  rate: rrand(1.0, 1.4)                 if hats[i]   == 1
          sample gpercs.choose, amp: rrand(0.5, second_half ? 1.4 : 1.1),
                                rate: rrand(0.5, 2.0)                           if one_in(g_prob)
          sleep 0.5
        end
      end
    end
  end
end

sleep 448
