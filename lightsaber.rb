use_bpm 185
SONG_END = 22

# Section map (each tick = 16 beats = ~5.2s at 185 BPM):
#   0- 1  intro       10.4s  — silence
#   2- 4  verse 1     15.6s  — closed hat, one crash-hit per tick
#   5- 6  chorus      10.4s  — METAL hat, crash every measure, bass → A
#   7-10  verse 2     20.8s  — closed hat, hit at end of each tick, bass → E
#  11-17  outro       36.3s  — closed hat, no crash, bass → E drone
#  18-20  blast       15.6s  — metal hat, d-beat, bass → E pulse
#     21  ending       5.2s  — 2 blast measures then silence

# — Sounds —

define :kick do
  sample :bd_fat, amp: 1.3, attack: 0, sustain: 0.1, release: 0.15
end

define :snare do
  sample :sn_dub, amp: 1.0
end

define :hat do
  sample :hat_snap, amp: 0.7, rate: 1.5
end

define :hat_m do
  sample :hat_metal, amp: 0.75
end

define :crash do
  sample :hat_cymbal, amp: 0.9, rate: 0.65
end

# — Measures (each = 4 beats) —

define :mhat do
  8.times { hat; sleep 0.5 }
end

# Verse / outro: closed hat, kick 1+3, snare 2+4
define :mfull do
  kick; hat;  sleep 0.5
  hat;        sleep 0.5
  snare; hat; sleep 0.5
  hat;        sleep 0.5
  kick; hat;  sleep 0.5
  hat;        sleep 0.5
  snare; hat; sleep 0.5
  hat;        sleep 0.5
end

# Chorus: metal hat — open, heavy, distinct from verse
define :mchorus do
  kick; hat_m;  sleep 0.5
  hat_m;        sleep 0.5
  snare; hat_m; sleep 0.5
  hat_m;        sleep 0.5
  kick; hat_m;  sleep 0.5
  hat_m;        sleep 0.5
  snare; hat_m; sleep 0.5
  hat_m;        sleep 0.5
end

# Blast: d-beat, snare every 8th note, metal hat
define :mblast do
  kick;  hat_m; sleep 0.5
  snare; hat_m; sleep 0.5
  kick;  hat_m; sleep 0.5
  snare; hat_m; sleep 0.5
  kick;  hat_m; sleep 0.5
  snare; hat_m; sleep 0.5
  kick;  hat_m; sleep 0.5
  snare; hat_m; sleep 0.5
end

# — Loops —

live_loop :conductor do
  t = tick
  stop if t > SONG_END
  sleep 16
end

live_loop :drums, sync: :conductor do
  t = tick
  stop if t >= SONG_END

  case t
  when 0, 1
    # Intro: silence
    sleep 16

  when 2, 3, 4
    # Verse 1: crash on measure 1, hat holds through measures 2-4
    crash; mfull
    3.times { mhat }

  when 5, 6
    # Chorus: crash every measure, open metal hat
    4.times { crash; mchorus }

  when 7, 8, 9
    # Verse 2: hat leads, crash-hit on measure 3, hat trails
    2.times { mhat }
    crash; mfull
    mhat

  when 10
    # Verse 2 end: hat, pickup, big crash into outro
    2.times { mhat }
    mfull
    crash; mfull

  when 11
    # Outro entry: one big crash
    crash
    4.times { mfull }

  when 12..17
    # Outro: driving closed-hat beat
    4.times { mfull }

  when 18..20
    # Blast: d-beat escalation
    4.times { mblast }

  when 21
    # Ending: two blast measures then silence
    crash; mblast; mblast
    sleep 8
  end
end

live_loop :bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END

  use_synth :chipbass

  case t
  when 0, 1
    sleep 16

  when 2, 3, 4
    # Verse 1: staccato E on the downbeat hit
    play :e2, amp: 0.7, sustain: 0.4, release: 0.2
    sleep 16

  when 5, 6
    # Chorus: A root — the "other stuff"
    play :a2, amp: 0.8, sustain: 14, release: 2
    sleep 16

  when 7, 8, 9
    # Verse 2: E on the hit (measure 3 of each tick)
    sleep 8
    play :e2, amp: 0.7, sustain: 0.4, release: 0.2
    sleep 8

  when 10
    # Verse 2 end: E on the big hit (measure 4)
    sleep 12
    play :e2, amp: 0.9, sustain: 0.4, release: 0.2
    sleep 4

  when 11..17
    # Outro: sustained E drone
    play :e2, amp: 0.65, sustain: 14, release: 2
    sleep 16

  when 18..20
    # Blast: driving E pulse every beat
    4.times do
      play :e2, amp: 0.85, sustain: 0.6, release: 0.2
      sleep 4
    end

  when 21
    play :e2, amp: 0.8, sustain: 6, release: 2
    sleep 16
  end
end
