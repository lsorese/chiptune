# interlude_1.rb — "static march"
# 160 BPM | ~2 min | B | 4-on-floor kick + glitch fills + noise wall
#
# run_file "/Users/logan/Projects/chiptune/set6/interlude_1.rb"

use_bpm 160

gpercs = [
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc2.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc4.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac",
]
noise_loop = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-pink.wav"
dark_noise = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-dark-pink.wav"

# dual noise wall
in_thread do
  sample noise_loop, amp: 0.55, attack: 3.0, sustain: 116.0, release: 3.0
  sample dark_noise, amp: 0.45, attack: 1.0, sustain: 120.0, release: 1.0
end

# B sub-bass slab
in_thread do
  with_fx :bitcrusher, bits: 3, sample_rate: 0.10 do
    with_fx :distortion, distort: 0.95 do
      use_synth :chipbass
      play :b0, sustain: 120.0, release: 6.0, amp: 2.2, cutoff: 55
      play :b1, sustain: 116.0, release: 6.0, amp: 1.2, cutoff: 62
    end
  end
  sleep 352
end

# main drums — 4-on-floor with glitch fills (11 × 32 = 352 beats)
in_thread do
  with_fx :distortion, distort: 0.5 do
    11.times do
      8.times do
        sample :bd_haus, amp: rrand(1.9, 2.4)
        sample gpercs.choose, amp: rrand(0.4, 0.9), rate: rrand(0.7, 1.5) if one_in(3)
        sleep 1
        sample :sn_dolf, amp: 1.8, rate: 0.95
        sample :hat_snap, amp: 0.6 if one_in(2)
        sleep 1
        sample :bd_haus, amp: rrand(1.7, 2.2)
        sample :bd_haus, amp: 1.5 if one_in(3)   # occasional double kick
        sample gpercs.choose, amp: rrand(0.3, 0.8), rate: rrand(0.5, 2.0) if one_in(3)
        sleep 1
        sample :sn_dolf, amp: 2.0, rate: 1.0
        sample :hat_snap, amp: 0.7
        sleep 1
      end
    end
  end
end

sleep 352
