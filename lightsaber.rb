use_bpm 185
SONG_END = 22

define :kick do
  sample :bd_fat, amp: 1.4, attack: 0, sustain: 0.1, release: 0.15
end

define :snare do
  sample :sn_dub, amp: 1.1
end

define :hat do
  sample :hat_snap, amp: 0.7, rate: 1.5
end

define :hat_m do
  sample :hat_metal, amp: 0.8
end

define :crash do
  sample :hat_cymbal, amp: 1.0, rate: 0.6
end

define :hit do
  sample :bd_fat, amp: 1.6, attack: 0, sustain: 0.1, release: 0.15
  sample :sn_dub, amp: 1.4
  crash
end

# Verse: 8th-note hats, then fill at end of line
# Dum Dum Dum Dum (gap) Dum Dum Dum Dum
define :m_verse do |first|
  if first
    hit; sleep 0.5
  else
    kick; sleep 0.5
  end
  # Beats 0.5-11.5: 8th-note hats
  22.times { hat; sleep 0.5 }
  # Beats 12.5-16: fill — 4 hits, 1-beat gap, 4 hits
  hat; sleep 0.5
  kick; snare; sleep 0.5
  kick; snare; sleep 0.5
  kick; snare; sleep 0.5
  kick; snare; sleep 1.0
  kick; snare; sleep 0.5
  kick; snare; sleep 0.5
  kick; snare; sleep 0.5
end

# Chorus: kick+snare on every beat, metal hats on every 8th
define :m_chorus do
  kick; snare; hat_m; sleep 0.5
  hat_m;              sleep 0.5
  kick; snare; hat_m; sleep 0.5
  hat_m;              sleep 0.5
  kick; snare; hat_m; sleep 0.5
  hat_m;              sleep 0.5
  kick; snare; hat_m; sleep 0.5
  hat_m;              sleep 0.5
end

# Outro: kick 1+3, snare 2+4, hats on 8ths
define :m_outro do
  kick; hat;  sleep 0.5
  hat;        sleep 0.5
  snare; hat; sleep 0.5
  hat;        sleep 0.5
  kick; hat;  sleep 0.5
  hat;        sleep 0.5
  snare; hat; sleep 0.5
  hat;        sleep 0.5
end

# Blast: kick+snare alternating on every 8th, metal hats
define :m_blast do
  kick;  hat_m; sleep 0.5
  snare; hat_m; sleep 0.5
  kick;  hat_m; sleep 0.5
  snare; hat_m; sleep 0.5
  kick;  hat_m; sleep 0.5
  snare; hat_m; sleep 0.5
  kick;  hat_m; sleep 0.5
  snare; hat_m; sleep 0.5
end

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
    sleep 16

  when 2
    m_verse true

  when 3, 4
    m_verse false

  when 5, 6
    crash
    4.times { m_chorus }

  when 7
    m_verse true

  when 8, 9, 10
    m_verse false

  when 11
    crash
    2.times { m_outro }
    2.times { m_blast }

  when 12, 13, 14
    4.times { m_blast }

  when 15, 16, 17
    crash
    4.times { m_blast }

  when 18, 19, 20
    crash
    4.times { m_blast }

  when 21
    crash; m_blast; m_blast
    sleep 8
  end
end
