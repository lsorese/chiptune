# killer_oh.rb
# Inspired by: GO! with fourteen o - "Killer Oh (Guns Over Friends Mix)" (Track 8)
# 162 BPM  |  Bb minor  |  Bbm – Gb – Fm – Ebm
#
# Open style — no synth melody, space for guitar/vocals on top.
# Same energy as gun_fingers but in Bb minor (descending minor, same shape).
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/killer_oh.rb"

use_bpm 162

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Bitcrushed descending stabs (chorus only) ─────────────────────────────────
# 2 passes × 4 chords × (8×0.25 + sleep 2) = 32 beats
STABS = [
  [:bb5, :f5,  :db5, :bb4, :f4,  :db4, :f4,  :bb4],
  [:gb5, :db5, :bb4, :gb4, :db4, :bb3, :db4, :gb4],
  [:f5,  :c5,  :ab4, :f4,  :c4,  :ab3, :c4,  :f4 ],
  [:eb5, :bb4, :gb4, :eb4, :bb3, :gb3, :bb3, :eb4],
]

live_loop :scream_lead, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 6, sample_rate: 0.4 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.08, release: 0.06,
                         amp: 0.55, pulse_width: 0.15, cutoff: 100
      2.times do
        STABS.each do |pattern|
          pattern.each { |n| play n; sleep 0.25 }
          sleep 2
        end
      end
    end
  else
    sleep 32
  end
end

# ── Chip bass (Bbm–Gb–Fm–Ebm, 32 beats) ──────────────────────────────────────
BASS_ROOTS    = [:bb2, :gb2, :f2,  :eb2]
BASS_ROOTS_UP = [:bb3, :gb3, :f3,  :eb3]
BASS_WALK     = [:db3, :bb2, :ab2, :gb2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = [1, 3].include?(sec) ? 2.0 : 1.5

  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: bass_amp

    2.times do
      BASS_ROOTS.each_with_index do |root, i|
        play root;               sleep 0.5
        play root;               sleep 0.5
        play BASS_WALK[i];       sleep 0.5
        play root;               sleep 0.5
        play BASS_ROOTS_UP[i];   sleep 0.5
        play root;               sleep 0.5
        play BASS_ROOTS_UP[i];   sleep 0.5
        play BASS_WALK[i];       sleep 0.5
      end
    end
  end
end

# ── Kick  (32 beats = 8× 4-beat bar) ─────────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  8.times do
    if [1, 3].include?(sec)
      sample :bd_haus, amp: 2.2; sleep 0.5
      sample :bd_haus, amp: 1.8; sleep 0.5
      sleep 1
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.6; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.5
      sleep 1
    else
      sample :bd_haus, amp: 2.0; sleep 0.5
      sample :bd_haus, amp: 1.4; sleep 0.5
      sleep 1
      sample :bd_haus, amp: 2.0; sleep 0.5
      sample :bd_haus, amp: 1.3; sleep 0.5
      sleep 1
    end
  end
end

# ── Snare  (32 beats) ─────────────────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  8.times do
    if [1, 3].include?(sec)
      sleep 1
      sample :sn_dolf, amp: 2.2, rate: 0.9
      sleep 2
      sample :sn_dolf, amp: 2.4, rate: 0.88
      sleep 1
    else
      sleep 1
      sample :sn_dolf, amp: 1.8, rate: 1.1
      sleep 1.5
      sample :sn_dolf, amp: 0.7, rate: 1.3
      sleep 0.5
      sample :sn_dolf, amp: 2.0, rate: 0.98
      sleep 1
    end
  end
end

# ── Hats  (32 beats) ──────────────────────────────────────────────────────────
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    128.times do |i|
      if i % 4 == 0
        sample :drum_cymbal_open, amp: 0.85, finish: 0.05
      else
        sample :hat_snap, amp: 0.6, rate: 1.5
      end
      sleep 0.25
    end
  else
    64.times do |i|
      sample :hat_snap, amp: 1.1, rate: 0.95 if i.odd?
      sleep 0.5
    end
  end
end

# ── Crash  (32 beats, chorus only) ───────────────────────────────────────────
live_loop :crash, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  8.times do
    if [1, 3].include?(sec)
      sample :drum_cymbal_open, amp: 0.9, finish: 0.25
    end
    sleep 4
  end
end
