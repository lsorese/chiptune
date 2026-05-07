# gun_fingers.rb
# Inspired by: GO! with fourteen o - "Made A Gun With My Fingers And Shot At My Friends"
# 162 BPM  |  G minor  |  Gm – Eb – Dm – Cm
#
# Structure: verse1 → chorus → verse2 → chorus  (each section = 2× 32-beat pass)
# Total: 8 arp_lead iterations × 32 beats = 256 beats ≈ 95 seconds
# SONG_END controls how many iterations before everything stops.

use_bpm 162

SONG_END = 8  # 8 iterations = verse/chorus/verse/chorus, each played twice through

# ── Melodies ─────────────────────────────────────────────────────────────────
# G natural minor: G A Bb C D Eb F
# Mostly quarter notes — stays out of the way of a vocal on top.
# D→Eb→D sting appears once per melody as a rhythmic accent.

define :verse1 do
  # Pass 1 (16 beats) — low, steady, quarter notes

  # Bar 1 – Gm
  play :d5;  sleep 1
  play :bb4; sleep 1
  play :g4;  sleep 1
  play :d5;  sleep 1

  # Bar 2 – Eb
  play :eb5; sleep 2    # half note — dark held Eb
  play :g4;  sleep 1
  play :bb4; sleep 1

  # Bar 3 – Dm
  play :a4;  sleep 1
  play :f4;  sleep 1
  play :d4;  sleep 1
  play :a4;  sleep 1

  # Bar 4 – Cm
  play :g4;  sleep 1
  play :eb4; sleep 1
  play :c4;  sleep 1
  play :g4;  sleep 1

  # Pass 2 (16 beats) — sting on bar 1 beat 2, otherwise same shape

  # Bar 1 – Gm
  play :d5;  sleep 1
  play :eb5; sleep 0.5  # sting
  play :d5;  sleep 0.5
  play :bb4; sleep 1
  play :g4;  sleep 1

  # Bar 2 – Eb
  play :eb5; sleep 2
  play :bb4; sleep 1
  play :g4;  sleep 1

  # Bar 3 – Dm
  play :f4;  sleep 1
  play :a4;  sleep 1
  play :d5;  sleep 1
  play :f4;  sleep 1

  # Bar 4 – Cm
  play :eb4; sleep 1
  play :c4;  sleep 1
  play :g4;  sleep 1
  play :c5;  sleep 1
end

define :verse2 do
  # Pass 1 (16 beats) — starts on G5, descends

  # Bar 1 – Gm
  play :g5;  sleep 1
  play :f5;  sleep 1
  play :eb5; sleep 1
  play :d5;  sleep 1

  # Bar 2 – Eb
  play :bb4; sleep 1
  play :g4;  sleep 1
  play :eb5; sleep 2

  # Bar 3 – Dm
  play :d5;  sleep 1
  play :a4;  sleep 1
  play :f4;  sleep 2

  # Bar 4 – Cm
  play :g4;  sleep 1
  play :eb4; sleep 1
  play :c4;  sleep 2

  # Pass 2 (16 beats) — climbs back, sting in bar 3

  # Bar 1 – Gm
  play :d5;  sleep 1
  play :g5;  sleep 1
  play :bb5; sleep 2

  # Bar 2 – Eb
  play :g5;  sleep 1
  play :eb5; sleep 1
  play :bb4; sleep 1
  play :eb5; sleep 1

  # Bar 3 – Dm — sting
  play :a4;  sleep 1
  play :eb5; sleep 0.5  # sting over Dm
  play :d5;  sleep 0.5
  play :a4;  sleep 1
  play :f4;  sleep 1

  # Bar 4 – Cm
  play :g4;  sleep 1
  play :eb4; sleep 1
  play :c4;  sleep 1
  play :g4;  sleep 1
end

define :chorus_mel do
  # Pass 1 (16 beats) — climbs to peak at Eb6

  # Bar 1 – Gm
  play :g5;  sleep 1
  play :bb5; sleep 1
  play :d6;  sleep 1
  play :bb5; sleep 1

  # Bar 2 – Eb
  play :eb6; sleep 2    # peak — held half note
  play :bb5; sleep 1
  play :g5;  sleep 1

  # Bar 3 – Dm
  play :d5;  sleep 1
  play :f5;  sleep 1
  play :a5;  sleep 1
  play :f5;  sleep 1

  # Bar 4 – Cm
  play :eb5; sleep 1
  play :c5;  sleep 1
  play :g5;  sleep 1
  play :c6;  sleep 1

  # Pass 2 (16 beats) — descent with quick sting at top

  # Bar 1 – Gm — sting at start
  play :d6;  sleep 0.75
  play :eb6; sleep 0.25  # sting
  play :d6;  sleep 1
  play :bb5; sleep 1
  play :g5;  sleep 1

  # Bar 2 – Eb
  play :eb5; sleep 1
  play :g5;  sleep 1
  play :bb5; sleep 1
  play :eb6; sleep 1

  # Bar 3 – Dm
  play :d6;  sleep 1
  play :a5;  sleep 1
  play :f5;  sleep 1
  play :d5;  sleep 1

  # Bar 4 – Cm
  play :c5;  sleep 1
  play :eb5; sleep 1
  play :g5;  sleep 1
  play :c6;  sleep 1
end

# 16-beat drum-free intro = verse1 pass 1
define :intro do
  play :d5;  sleep 1
  play :bb4; sleep 1
  play :g4;  sleep 1
  play :d5;  sleep 1
  play :eb5; sleep 2
  play :g4;  sleep 1
  play :bb4; sleep 1
  play :a4;  sleep 1
  play :f4;  sleep 1
  play :d4;  sleep 1
  play :a4;  sleep 1
  play :g4;  sleep 1
  play :eb4; sleep 1
  play :c4;  sleep 1
  play :g4;  sleep 1
end

# ── Lead ──────────────────────────────────────────────────────────────────────
# t=0: 16-beat intro (drums miss this, arrive at t=1).
# t=1..8: normal 32-beat sections. sec = ((t-1)/2) % 4.
live_loop :arp_lead do
  t = tick
  stop if t > SONG_END  # plays t=0..8 (intro + 8 main sections)

  with_fx :reverb, room: 0.7, mix: 0.2 do
    with_fx :distortion, distort: 0.5 do
      use_synth :pulse
      use_synth_defaults attack: 0.01, sustain: 0.15, release: 0.10,
                         amp: 0.55, pulse_width: 0.12, cutoff: 82
      if t == 0
        intro
      else
        sec = ((t - 1) / 2) % 4
        case sec
        when 0 then verse1
        when 1 then chorus_mel
        when 2 then verse2
        when 3 then chorus_mel
        end
      end
    end
  end
end

# ── Bitcrushed counter stabs (chorus only) ───────────────────────────────────
# Each STABS pass: 4 patterns × (8 × 0.25 + sleep 2) = 16 beats. 2× = 32 beats.
STABS = [
  [:g6,  :d6,  :bb5, :g5,  :d5,  :bb4, :g5,  :d6 ],
  [:eb6, :bb5, :g5,  :eb5, :bb4, :g4,  :bb4, :eb5],
  [:d6,  :a5,  :f5,  :d5,  :a4,  :f4,  :a4,  :d5 ],
  [:c6,  :g5,  :eb5, :c5,  :g4,  :eb4, :g4,  :c5 ],
]

live_loop :scream_lead, sync: :arp_lead do
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

# ── Chip bass (32 beats = 2× 16-beat Gm–Eb–Dm–Cm pattern) ───────────────────
BASS_ROOTS = [:g2,  :eb2, :d2,  :c2 ]
BASS_WALK  = [:bb2, :g2,  :f2,  :eb2]

live_loop :chip_bass, sync: :arp_lead do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = [1, 3].include?(sec) ? 2.0 : 1.5

  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: bass_amp
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
live_loop :kick, sync: :arp_lead do
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
live_loop :snare, sync: :arp_lead do
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
      sleep 1.875
      sample :sn_dolf, amp: 0.9, rate: 1.2
      sleep 0.125
      sample :sn_dolf, amp: 2.0, rate: 0.98
      sleep 1
    end
  end
end

# ── Hats  (32 beats) ──────────────────────────────────────────────────────────
live_loop :hats, sync: :arp_lead do
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
live_loop :crash, sync: :arp_lead do
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
