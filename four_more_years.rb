# four_more_years.rb
# Inspired by: GO! with fourteen o - "Four More Years"
# 148 BPM  |  Eb minor  |  Ebm – B – Bbm – Gb
#
# Melody appears once — first chorus only.
# Everything else is bass, drums, and arp sweeps.
#
# Structure: 16-beat intro → verse → CHORUS (melody) → verse → chorus
# SONG_END = 8

use_bpm 148

SONG_END = 8

# ── Melody (first chorus only) ───────────────────────────────────────────────
# Eb natural minor: Eb F Gb Ab Bb Cb(=B) Db
define :chorus do
  # Pass 1 (16 beats) — big arch, high register

  play :gb5; sleep 1
  play :eb5; sleep 1
  play :bb5; sleep 2

  play :d6;  sleep 2
  play :b5;  sleep 1
  play :gb5; sleep 1

  play :f5;  sleep 1
  play :db5; sleep 1
  play :bb4; sleep 2

  play :bb5; sleep 1
  play :gb5; sleep 1
  play :eb5; sleep 2

  # Pass 2 (16 beats) — peak at Eb6, chromatic passing tone Ab, descent

  play :eb6; sleep 2
  play :bb5; sleep 1
  play :gb5; sleep 1

  play :b5;  sleep 1
  play :gb5; sleep 0.75
  play :ab5; sleep 0.25  # Ab over B = bleak
  play :gb5; sleep 2

  play :bb5; sleep 1
  play :f5;  sleep 1
  play :db5; sleep 2

  play :eb5; sleep 1
  play :db5; sleep 1
  play :bb4; sleep 1
  play :gb4; sleep 1
end

# ── Lead conductor ────────────────────────────────────────────────────────────
# Melody plays only in sec=1 (first chorus). Silent everywhere else.
# t=0: 16-beat silent intro (drums miss this fire, arrive at t=1).
live_loop :chip_lead do
  t = tick
  stop if t > SONG_END

  if t == 0
    sleep 16
  else
    sec = ((t - 1) / 2) % 4
    if sec == 1
      with_fx :reverb, room: 0.85, mix: 0.3 do
        with_fx :echo, phase: 0.25, decay: 2.0, mix: 0.15 do
          use_synth :pulse
          use_synth_defaults attack: 0.02, sustain: 0.35, release: 0.18,
                             amp: 0.5, pulse_width: 0.45, cutoff: 78
          chorus
        end
      end
    else
      sleep 32
    end
  end
end

# ── Ascending arp sweeps (both choruses) ─────────────────────────────────────
# 4 chords × 8 notes × 0.5 × 2 passes = 32 beats
ARP_SWEEPS = [
  [:eb4, :gb4, :bb4, :eb5, :gb5, :bb5, :eb6, :bb5],  # Ebm
  [:b3,  :eb4, :gb4, :b4,  :eb5, :gb5, :b5,  :gb5],  # B
  [:bb3, :db4, :f4,  :bb4, :db5, :f5,  :bb5, :f5 ],  # Bbm
  [:gb3, :bb3, :db4, :gb4, :bb4, :db5, :gb5, :db5],  # Gb
]

live_loop :sweep_arp, sync: :chip_lead do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    with_fx :bitcrusher, bits: 7, sample_rate: 0.5 do
      with_fx :echo, phase: 0.5, decay: 1.5, mix: 0.2 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.1, release: 0.08,
                           amp: 0.4, pulse_width: 0.15, cutoff: 95
        2.times do
          ARP_SWEEPS.each do |chord|
            chord.each { |n| play n; sleep 0.5 }
          end
        end
      end
    end
  else
    sleep 32
  end
end

# ── Bass (root–root–fifth–up–root–seventh–fifth–up, 8th notes, 32 beats) ─────
BASS_ROOTS    = [:eb2, :b1,  :bb1, :gb1]
BASS_ROOTS_UP = [:eb3, :b2,  :bb2, :gb2]
BASS_FIFTHS   = [:bb2, :gb2, :f2,  :db2]
BASS_SEVENTHS = [:db3, :a2,  :ab2, :e2 ]

live_loop :chip_bass, sync: :chip_lead do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  bass_amp = [1, 3].include?(sec) ? 2.2 : 1.7

  with_fx :distortion, distort: 0.6 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.22, release: 0.06, amp: bass_amp

    2.times do
      BASS_ROOTS.each_with_index do |root, i|
        up  = BASS_ROOTS_UP[i]
        fi  = BASS_FIFTHS[i]
        sev = BASS_SEVENTHS[i]
        play root; sleep 0.5
        play root; sleep 0.5
        play fi;   sleep 0.5
        play up;   sleep 0.5
        play root; sleep 0.5
        play sev;  sleep 0.5
        play fi;   sleep 0.5
        play up;   sleep 0.5
      end
    end
  end
end

# ── Kick  (32 beats = 8× 4-beat bar) ─────────────────────────────────────────
live_loop :kick, sync: :chip_lead do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  8.times do
    if [1, 3].include?(sec)
      sample :bd_fat, amp: 2.5; sleep 0.5
      sample :bd_fat, amp: 2.0; sleep 0.5
      sleep 1
      sample :bd_fat, amp: 2.5; sleep 0.5
      sample :bd_fat, amp: 1.8; sleep 0.5
      sleep 1
    else
      sample :bd_fat, amp: 2.2; sleep 1
      sleep 0.75
      sample :bd_fat, amp: 0.9; sleep 0.25
      sample :bd_fat, amp: 2.0; sleep 1
      sleep 1
    end
  end
end

# ── Snare  (32 beats) ─────────────────────────────────────────────────────────
live_loop :snare, sync: :chip_lead do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  8.times do
    if [1, 3].include?(sec)
      sleep 1
      sample :sn_dub, amp: 2.2, rate: 0.9
      sleep 2
      sample :sn_dub, amp: 2.5, rate: 0.88
      sleep 1
    else
      sleep 1
      sample :sn_dub, amp: 1.8, rate: 1.05
      sleep 2
      sample :sn_dub, amp: 2.0, rate: 1.0
      sleep 1
    end
  end
end

# ── Hats  (32 beats) ──────────────────────────────────────────────────────────
live_loop :hats, sync: :chip_lead do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 3].include?(sec)
    128.times do |i|
      sample :hat_metal, amp: (i % 16 == 0) ? 1.0 : 0.5,
                         rate: (i % 16 == 0) ? 0.7 : 1.2
      sleep 0.25
    end
  else
    64.times do |i|
      sample :hat_metal, amp: (i % 8 == 0) ? 0.9 : 0.5,
                         rate: (i % 8 == 0) ? 0.8 : 1.1
      sleep 0.5
    end
  end
end

# ── Crash  (32 beats, chorus only) ───────────────────────────────────────────
live_loop :crash, sync: :chip_lead do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  8.times do
    if [1, 3].include?(sec)
      sample :drum_cymbal_open, amp: 0.8, finish: 0.3
    end
    sleep 4
  end
end
