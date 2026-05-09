# intro.rb
# 60 BPM  |  A minor  |  somber chiptune intro → dissonant cluster → first track
#
# 0:00–0:24 — bass + two melody channels (left / right), each note sustains
#             until the next hit on that side, then hard-cuts
# 0:24–0:30 — chromatic sweep, one pitch at a time, each in 8 octaves, noise blast
#
# run_file "/Users/logan/Projects/chiptune/set5/0. intro.rb"

use_bpm 60

osc_send "localhost", 4559, "/sp/intro/section", 0

with_fx :reverb, room: 0.3, mix: 0.12 do

  # ── 24 beats: bass + sustained stereo melody ────────────────────────────────

  # bass: roots and fifths, gently panned opposite to the melody on each bar
  in_thread do
    use_synth :chipbass
    [
      [:a2, :e3, -1], [:f2, :c3,  1],
      [:c2, :g2, -1], [:e2, :b2,  1],
      [:a2, :e3, -1], [:f2, :c3,  1],
    ].each do |root, fifth, p|
      play root,  sustain: 2.6, release: 0.7, amp: 1.8, pan: p * 0.5
      sleep 2
      play fifth, sustain: 2.5, release: 0.7, amp: 1.5, pan: -p * 0.5
      sleep 2
    end
  end

  # left channel: note holds until next left-side note, then hard-cuts
  # e4→a3→g3→a3→a4→e4  (derived from mel1 of odd bars + mel2 of even bars)
  in_thread do
    use_synth :pulse
    [[:e4, 6], [:a3, 2], [:g3, 6], [:a3, 2], [:a4, 6], [:e4, 2]].each do |n, dur|
      play n, pan: -1, amp: 0.58, attack: 0.05, sustain: dur - 0.1, release: 0.05,
              pulse_width: 0.25, cutoff: 78
      sleep dur
    end
  end

  # right channel: starts 2 beats in, same hard-cut behavior
  # d4→c4→e3→b3→g4→f4
  in_thread do
    sleep 2
    use_synth :pulse
    [[:d4, 2], [:c4, 6], [:e3, 2], [:b3, 6], [:g4, 2], [:f4, 4]].each do |n, dur|
      play n, pan: 1, amp: 0.58, attack: 0.05, sustain: dur - 0.1, release: 0.05,
              pulse_width: 0.25, cutoff: 78
      sleep dur
    end
  end

  sleep 24

  # ── 6 beats: ascending chromatic sweep, each pitch added in all 8 octaves ───
  in_thread do
    use_synth :chipbass
    play :a2, sustain: 7.0, release: 1.5, amp: 2.5
    play :e3, sustain: 7.0, release: 1.5, amp: 2.0
  end

  with_fx :bitcrusher, bits: 6, sample_rate: 0.4 do
    use_synth :pulse
    use_synth_defaults attack: 0, sustain: 9.0, release: 2.0,
                       pulse_width: 0.5, cutoff: 130

    bases   = [note(:a2), note(:bb2), note(:b2),  note(:c3),
               note(:cs3), note(:d3),  note(:eb3), note(:e3),
               note(:f3),  note(:fs3), note(:g3),  note(:gs3)]
    timings = [0.75, 0.75, 0.75,
               0.5,  0.5,  0.5,
               0.3,  0.3,  0.3,
               0.15, 0.15, 0.15]

    bases.each_with_index do |base, i|
      (-2..5).each do |oct|
        play base + (oct * 12), amp: 0.35
      end
      sleep timings[i]
    end

    # all 96 notes ringing — noise blast on top
    with_synth :noise do
      play :a3, sustain: 1.5, release: 0.5, amp: 2.0
    end
    with_synth :bnoise do
      play :a2, sustain: 1.5, release: 0.5, amp: 1.8
    end
    sleep 0.9   # total chaos section = 6.0 beats
  end

end
