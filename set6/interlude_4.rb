# interlude_4.rb — "pressure drop"
# 200 BPM | ~2 min | Bb | escalating drums — sparse kick → full blast beat over noise wall
#
# run_file "/Users/logan/Projects/chiptune/set6/interlude_4.rb"

use_bpm 200

gpercs = [
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc2.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc4.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac",
]
noise_loop = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-pink.wav"
dark_noise = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-dark-pink.wav"

# noise wall — loud from start
in_thread do
  sample noise_loop, amp: 0.60, attack: 1.0, sustain: 124.0, release: 1.0
  sample dark_noise, amp: 0.65, attack: 0.5, sustain: 125.0, release: 0.5
end

# Bb sub-bass — max crush
in_thread do
  with_fx :bitcrusher, bits: 3, sample_rate: 0.07 do
    with_fx :distortion, distort: 0.99 do
      use_synth :chipbass
      play :bb0, sustain: 124.0, release: 4.0, amp: 3.0, cutoff: 50
      play :f1,  sustain: 124.0, release: 4.0, amp: 1.5, cutoff: 44
    end
  end
  sleep 448
end

# escalating drums — 14 × 32 = 448 beats at 200 BPM = 134.4s ✓
# phase 1 (sections 0-3):  kick every 2 beats, no snare
# phase 2 (sections 4-7):  kick + snare on 2+4, glitch fills
# phase 3 (sections 8-13): full blast beat + everything
in_thread do
  with_fx :distortion, distort: 0.55 do
    14.times do |s|
      if s < 4
        # sparse kick only — 32 beats: 16 kick hits
        16.times do
          sample :bd_haus, amp: 2.2 + (s * 0.1)
          sleep 1
          sleep 1
        end
      elsif s < 8
        # kick + snare — standard 4/4
        8.times do
          sample :bd_haus, amp: 2.4
          sleep 1
          sample :sn_dolf, amp: 1.8, rate: 0.9
          sample gpercs.choose, amp: rrand(0.3, 0.7), rate: rrand(0.8, 1.5) if one_in(2)
          sleep 1
          sample :bd_haus, amp: 2.2
          sleep 1
          sample :sn_dolf, amp: 2.2, rate: 0.88
          sample gpercs.choose, amp: rrand(0.5, 1.0), rate: rrand(0.6, 1.8) if one_in(2)
          sleep 1
        end
      else
        # blast beat — 64 × 0.5 = 32 beats ✓
        64.times do |i|
          sample :bd_haus, amp: 2.8
          sample :sn_dolf, amp: 2.5, rate: 0.85 if i.odd?
          sample gpercs.choose, amp: rrand(0.6, 1.2), rate: rrand(0.5, 2.0) if one_in(3)
          sleep 0.5
        end
      end
    end
  end
end

sleep 448
