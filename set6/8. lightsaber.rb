use_bpm 185
SONG_END = 23

# Option D: structural change at 91.6s marked mid-t=17 (outro → blast)

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

define :m_verse do |first|
  if first
    hit; sleep 0.5
  else
    kick; sleep 0.5
  end
  22.times { hat; sleep 0.5 }
  hat; sleep 0.5
  kick; snare; sleep 0.5
  kick; snare; sleep 0.5
  kick; snare; sleep 0.5
  kick; snare; sleep 1.0
  kick; snare; sleep 0.5
  kick; snare; sleep 0.5
  kick; snare; sleep 0.5
end

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

  when 3, 4, 5
    m_verse false

  when 6, 7
    crash
    4.times { m_chorus }

  when 8
    m_verse true

  when 9, 10, 11, 12
    m_verse false

  when 13
    crash
    4.times { m_outro }

  when 14, 15, 16
    4.times { m_outro }

  when 17
    # structural change at ~91.6s = beat ~8 of this tick
    2.times { m_outro }
    crash
    2.times { m_blast }

  when 18, 19
    crash
    4.times { m_blast }

  when 20
    4.times { m_blast }

  when 21
    crash; m_blast; m_blast
    sleep 8
  end
end
