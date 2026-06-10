# civil_eyes.rb
# Inspired by: GO! with fourteen o - "Civil Eyes"
# 167 BPM  |  A minor  |  Am – F – Em – Dm
#
# Open style: bass + drums + STABS arp texture. No synth melody.
# Structure: 16-beat intro → 8× 32-beat sections
# SONG_END = 8
#
# run_file "/Users/logan/Projects/chiptune/civil_eyes_v1.rb"

use_bpm 167

SONG_END = 8

# ── Conductor ─────────────────────────────────────────────────────────────────
# t=0: 16-beat silent intro. All other loops sync here and start at t=1.
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep t == 0 ? 16 : 32
end

# ── Bitcrushed STABS arp (texture, not melody) ────────────────────────────────
# Descending minor arpeggios, A minor. 2× 4-chord pass = 32 beats.
# Each chord: 8 notes × 0.25 + sleep 2 = 4 beats. 4 chords × 4 = 16. 2× = 32.
STABS = [
  [:a6, :e6, :c6, :a5, :e5, :c5, :e5, :a5],  # Am
  [:f6, :c6, :a5, :f5, :c5, :a4, :c5, :f5],  # F
  [:e6, :b5, :g5, :e5, :b4, :g4, :b4, :e5],  # Em
  [:d6, :a5, :f5, :d5, :a4, :f4, :a4, :d5],  # Dm
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
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
end

# ── Bass (32 beats = 2× 4-chord × 8-step pattern) ────────────────────────────
# Am – F – Em – Dm  (i–VI–v–iv)
# Each chord: 8 steps × 0.5 = 4 beats. 4 chords × 2 passes = 32 beats.
BASS_ROOTS = [:a2, :f2, :e2, :d2]
BASS_WALK  = [:c3, :a2, :g2, :f2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: 2.0
    2.times do
      BASS_ROOTS.zip(BASS_WALK).each do |root, walk|
        play root;      sleep 0.5
        play root;      sleep 0.5
        play walk;      sleep 0.5
        play root;      sleep 0.5
        play root + 12; sleep 0.5
        play root;      sleep 0.5
        play root + 12; sleep 0.5
        play walk;      sleep 0.5
      end
    end
  end
end

# ── Kick  (32 beats = 8× 4-beat bar) ─────────────────────────────────────────
# Energetic double-hit pattern throughout.
# Bar: (0.5+0.5+1) + (0.25+0.25+0.5+1) = 4 beats. 8× = 32 beats.
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sample :bd_haus, amp: 2.2; sleep 0.5
    sample :bd_haus, amp: 1.8; sleep 0.5
    sleep 1
    sample :bd_haus, amp: 2.2; sleep 0.25
    sample :bd_haus, amp: 1.6; sleep 0.25
    sample :bd_haus, amp: 1.8; sleep 0.5
    sleep 1
  end
end

# ── Snare  (32 beats = 8× 4-beat bar) ────────────────────────────────────────
# 2+4 hits. Bar: sleep 1 + hit + sleep 2 + hit + sleep 1 = 4 beats. 8× = 32.
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sleep 1
    sample :sn_dolf, amp: 2.2, rate: 0.9
    sleep 2
    sample :sn_dolf, amp: 2.4, rate: 0.88
    sleep 1
  end
end

# ── Hats  (32 beats) ──────────────────────────────────────────────────────────
# 16th notes. Beat-1 of each bar (every 4th step) gets open cymbal accent.
# 128 steps × 0.25 = 32 beats.
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  128.times do |i|
    if i % 4 == 0
      sample :drum_cymbal_open, amp: 0.85, finish: 0.05
    else
      sample :hat_snap, amp: 0.6, rate: 1.5
    end
    sleep 0.25
  end
end

# ── Crash  (32 beats — downbeat of every bar) ────────────────────────────────
# 8 bars × sleep 4 = 32 beats.
live_loop :crash, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  8.times do
    sample :drum_cymbal_open, amp: 0.9, finish: 0.25
    sleep 4
  end
end
