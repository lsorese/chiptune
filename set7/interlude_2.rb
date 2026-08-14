# interlude_2.rb — "half-time gallop"  (set7: trimmed to ~96s)
# 140 BPM | Em | heavy half-time drums + fuzz wall
# kit: bd_boom / sn_zome
#
# run_file "/Users/logan/Projects/chiptune/set7/interlude_2.rb"

use_bpm 140

gpercs = [
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac",
]
dark_noise = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-dark-pink.wav"

# dark noise wall
in_thread do
  sample dark_noise, amp: 0.55, attack: 2.0, sustain: 92.0, release: 2.0
end

# Em fuzz wall — detuned distorted saws
in_thread do
  with_fx :distortion, distort: 0.96 do
    with_fx :bitcrusher, bits: 4, sample_rate: 0.18 do
      use_synth :saw
      [[:e1, 0.93, 0.0, 0.55], [:e2, 0.90, -0.8, 0.45],
       [:g2, 0.92, 0.6, 0.35], [:b2, 0.89, -0.4, 0.32]].each do |pitch, rate, pan, amp|
        play pitch, sustain: 96.0, release: 6.0,
                    amp: amp, pan: pan, rate: rate, cutoff: 78, attack: rrand(0.5, 2.0)
      end
    end
  end
  sleep 224
end

# main drums — half-time gallop: kick K.kk snare on 3
# 8 beats per bar: K . k k | Sn . . . (half-time = snare every 8 beats)
# 10 × 32 = 320 beats ✓
in_thread do
  with_fx :distortion, distort: 0.4 do
    7.times do
      4.times do
        sample :bd_boom, amp: 2.5, rate: 0.92    # beat 1
        sleep 1
        sleep 1                                    # beat 2
        sample :bd_boom, amp: 1.8, rate: 0.95    # beat 3 (gallop 1)
        sleep 0.5
        sample :bd_boom, amp: 2.0, rate: 0.93    # beat 3.5 (gallop 2)
        sleep 0.5
        sample :sn_zome, amp: 2.8, rate: 0.78    # beat 4 (half-time snare)
        sample gpercs.choose, amp: rrand(0.4, 0.9), rate: rrand(0.7, 1.4) if one_in(2)
        sleep 1
        sleep 1                                    # beat 5
        sleep 1                                    # beat 6
        sample :bd_boom, amp: 2.3, rate: 0.90    # beat 7 (gallop 1)
        sleep 0.5
        sample :bd_boom, amp: 1.9, rate: 0.94    # beat 7.5 (gallop 2)
        sleep 0.5
        sample :sn_zome, amp: 3.0, rate: 0.75    # beat 8 (heavy half-time snare)
        sample gpercs.choose, amp: rrand(0.5, 1.0), rate: rrand(0.6, 1.6) if one_in(2)
        sleep 1
      end
    end
  end
end

sleep 224
