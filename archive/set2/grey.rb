# grey.rb
# 138 BPM  |  A minor  |  Am – E – G – D  (harmonic minor — E major V chord)
#
# Syncopated bass: hits on beat 1, AND-of-2, beat 3, AND-of-4 (off-beat feel).
# Ascending arp in chorus. Ghost kick on AND-of-3. Ghost snare before beat 4.
# Cyber metal — space for screamed vocals.
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/set2/grey.rb"

use_bpm 138

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Ascending arp (chorus only) ───────────────────────────────────────────────
# 2 passes × 4 chords × 8 notes × sleep 0.5 = 32 beats ✓
GREY_ARP = [
  [:a4, :c5,  :e5, :a5,  :e5, :c5,  :a4, :e4 ],   # Am
  [:e4, :gs4, :b4, :e5,  :b4, :gs4, :e4, :b3 ],   # E major (harmonic V)
  [:g4, :b4,  :d5, :g5,  :d5, :b4,  :g4, :d4 ],   # G
  [:d4, :fs4, :a4, :d5,  :a4, :fs4, :d4, :a3 ],   # D
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 7, sample_rate: 0.45 do
      with_fx :echo, phase: 0.5, decay: 1.5, mix: 0.18 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.1, release: 0.08,
                           amp: 0.4, pulse_width: 0.18, cutoff: 88
        2.times do
          GREY_ARP.each do |chord|
            chord.each { |n| play n; sleep 0.5 }
          end
        end
      end
    end
  else
    sleep 32
  end
end

# ── Syncopated bass (hits on 1, AND-of-2, 3, AND-of-4) ───────────────────────
# Per chord: sleep1 + play+sleep0.5 + sleep0.5 + play+sleep1 + sleep0.5 + play+sleep0.5 + play+sleep0.5
# Simplified: play+sleep1, sleep0.5, play+sleep0.5, play+sleep1, sleep0.5, play+sleep0.5 = 4 beats ✓
# 2 passes × 4 chords × 4 beats = 32 ✓
BASS_ROOTS  = [:a2, :e2, :g2, :d2]
BASS_FIFTHS = [:e3, :b2, :d3, :a2]
BASS_WALK   = [:g2, :d2, :fs2, :cs2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = [1, 3].include?(sec) ? 2.0 : 1.6
  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.18, release: 0.06, amp: bass_amp
    2.times do
      BASS_ROOTS.zip(BASS_FIFTHS, BASS_WALK).each do |root, fifth, walk|
        play root;  sleep 1    # beat 1
        sleep 0.5              # beat 2 (rest)
        play fifth; sleep 0.5  # AND of 2
        play root;  sleep 1    # beat 3
        sleep 0.5              # beat 4 (rest)
        play walk;  sleep 0.5  # AND of 4
      end
    end
  end
end

# ── Kick (1+3 with ghost on AND-of-3, 32 beats) ───────────────────────────────
# 8 × (kick+sleep1 + sleep1 + kick+sleep0.5 + ghost+sleep0.5 + sleep1) = 8×4 = 32 ✓
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sample :bd_haus, amp: 2.0; sleep 1    # beat 1
    sleep 1                                # beat 2
    sample :bd_haus, amp: 2.0; sleep 0.5  # beat 3
    sample :bd_haus, amp: 0.9; sleep 0.5  # AND of 3 (ghost)
    sleep 1                                # beat 4
  end
end

# ── Snare (2+4 with ghost before beat 4, 32 beats) ────────────────────────────
# 8 × (sleep1 + snare + sleep1.75 + ghost + sleep0.25 + snare + sleep1) = 8×4 = 32 ✓
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 1
    sample :sn_dolf, amp: 2.0, rate: 1.0   # beat 2
    sleep 1.75
    sample :sn_dolf, amp: 0.5, rate: 1.4   # ghost before beat 4
    sleep 0.25
    sample :sn_dolf, amp: 2.2, rate: 0.95  # beat 4
    sleep 1
  end
end

# ── Hats (verse: off-beat 8ths; chorus: 16ths, 32 beats) ─────────────────────
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 0.85 : 0.4), rate: 1.3
      sleep 0.25
    end
  else
    64.times do |i|
      sample :hat_snap, amp: 0.9, rate: 1.0 if i.odd?
      sleep 0.5
    end
  end
end
