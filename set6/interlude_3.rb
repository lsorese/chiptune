# interlude_3.rb — "doom march"
# 120 BPM | ~2 min | Ab | ultra-slow doom kick + noise swells
#
# run_file "/Users/logan/Projects/chiptune/set6/interlude_3.rb"

use_bpm 120

gpercs = [
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc2.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc4.flac",
]
noise_loop = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-pink.wav"
dark_noise = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-dark-pink.wav"
ambi_buzz  = "/Users/logan/Projects/chiptune/samples/ambient/ambi_soft_buzz.flac"

# three noise layers
in_thread do
  sample noise_loop, amp: 0.50, attack: 4.0, sustain: 112.0, release: 4.0
  sample dark_noise, amp: 0.55, attack: 2.0, sustain: 116.0, release: 2.0
  sample ambi_buzz,  amp: 0.30, attack: 8.0, sustain: 104.0, release: 8.0
end

# Ab sub-bass — max crush
in_thread do
  with_fx :bitcrusher, bits: 3, sample_rate: 0.08 do
    with_fx :distortion, distort: 0.98 do
      use_synth :chipbass
      play :ab0, sustain: 124.0, release: 6.0, amp: 2.8, cutoff: 52
      play :eb1, sustain: 124.0, release: 6.0, amp: 1.4, cutoff: 46
    end
  end
  sleep 288
end

# doom drum pattern — kick on 1, snare on 3 (every 8 beats = very slow)
# each bar = 8 beats; 4 bars per 32-beat block; 9 × 32 = 288 beats ✓
in_thread do
  with_fx :distortion, distort: 0.7 do
    9.times do
      4.times do
        sample :bd_haus, amp: 3.2, rate: 0.60    # massive slow kick on beat 1
        sleep 1
        sleep 1
        sample :sn_dolf, amp: 3.0, rate: 0.68    # heavy snare on beat 3
        sample gpercs.choose, amp: rrand(0.5, 1.0), rate: rrand(0.3, 0.9) if one_in(2)
        sleep 1
        sample :bd_haus, amp: 2.4, rate: 0.65 if one_in(2)   # optional beat 4 kick
        sleep 1
        # 4-beat bar total: 1+1+1+1 = 4 ✓; 4 bars × 4 beats = 16... need 32 per block
        # Actually 4.times × 8 beats = 32 ✓ — need 8 beats per inner loop
        sample :bd_haus, amp: 2.8, rate: 0.62    # beat 5
        sleep 1
        sleep 1
        sample :sn_dolf, amp: 3.2, rate: 0.70    # beat 7 (heavy)
        sample gpercs.choose, amp: rrand(0.6, 1.1), rate: rrand(0.3, 0.8) if one_in(2)
        sleep 1
        sleep 1
      end
    end
  end
end

sleep 288
