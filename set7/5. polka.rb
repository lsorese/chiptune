# 5. polka.rb — set7: ACCELERANDO POLKA
# 170 → 185 → 200 → 210 → 225 BPM  |  D → G → E, each modulation on a new section
#
# Identity: the only major-key track in the set, and the only one that never
# stops speeding up. Oom-pah bass, bd_tek / sn_dolf / hat_tap, accordion-ish
# :pulse lead. It gets drunker as it goes.
#
# t=0,1  verse   @170  D — D–A–G–D, oom-pah, sparse melody
# t=2    chorus  @185  D — full melody, 16th hats
# t=3    verse   @185  G — modulation down a fifth: G–D–C–G
# t=4    chorus  @200  G — melody + counter-arp
# t=5    verse   @210  E — modulation up: E–B–A–E
# t=6    chorus  @210  E — everything
# t=7    sprint  @225  E — final lap, no let-up
#
# run_file "/Users/logan/Projects/chiptune/set7/5. polka.rb"

use_bpm 170

SONG_END = 8

def bpm_for(t)
  case t
  when 0, 1 then 170
  when 2, 3 then 185
  when 4    then 200
  when 5, 6 then 210
  else           225
  end
end

def sec_for(t)
  case t
  when 0, 1, 3, 5 then :verse
  when 7          then :sprint
  else                 :chorus
  end
end

# Semitone transposition per key region: D=0, G=+5, E=+2
def shift(t)
  return 0 if t < 3
  t < 5 ? 5 : 2
end

# ── Oom-pah bass, written in D and transposed ─────────────────────────────────
BASS_ROOTS  = [:d2, :a1, :g1, :d2]
BASS_FIFTHS = [:a2, :e2, :d2, :a2]

# ── Melodies, written in D and transposed ─────────────────────────────────────
VERSE_MEL = [
  [:d5, 1], [:fs5, 1], [:a5, 1], [:fs5, 1],
  [:e5, 1], [:cs5, 1], [:e5, 2],
  [:d5, 1], [:b4, 1],  [:d5, 1], [:g4, 1],
  [:fs4, 1], [:a4, 1], [:d5, 2],
]

CHORUS_MEL = [
  [:a5, 0.5], [:fs5, 0.5], [:d5, 1], [:fs5, 1], [:a5, 1],
  [:cs6, 0.5], [:a5, 0.5], [:e5, 1], [:a5, 1], [:cs5, 1],
  [:b5, 0.5], [:g5, 0.5],  [:d5, 1], [:g5, 1], [:b5, 1],
  [:a5, 0.5], [:fs5, 0.5], [:d5, 1], [:fs5, 1], [:d5, 1],
]

ARP_CHORDS = [
  [:d4,  :fs4, :a4,  :fs4],
  [:cs4, :e4,  :a4,  :e4 ],
  [:b3,  :d4,  :g4,  :d4 ],
  [:a3,  :d4,  :fs4, :d4 ],
]

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  use_bpm bpm_for(t.zero? ? 0 : t - 1)
  osc_send "localhost", 4559, "/sp/polka/section", t
  sleep t.zero? ? 16 : 32
end

# ── Lead ──────────────────────────────────────────────────────────────────────
live_loop :lead, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  sh  = shift(t)
  with_fx :bitcrusher, bits: 7, sample_rate: 0.5 do
    use_synth :pulse
    use_synth_defaults attack: 0.002, sustain: 0.1, release: 0.04,
                       pulse_width: 0.22, cutoff: 100, amp: 0.85
    case sec
    when :verse
      2.times { VERSE_MEL.each { |n, d| play note(n) + sh; sleep d } }
    when :sprint
      # chorus melody, but doubled an octave up on the second pass
      CHORUS_MEL.each { |n, d| play note(n) + sh; sleep d }
      CHORUS_MEL.each { |n, d| play note(n) + sh; play note(n) + sh + 12, amp: 0.5; sleep d }
    else
      2.times { CHORUS_MEL.each { |n, d| play note(n) + sh; sleep d } }
    end
  end
end

# ── Counter-melody arp (chorus + sprint) ──────────────────────────────────────
live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  if sec_for(t) == :verse
    sleep 32
  else
    sh = shift(t)
    with_fx :bitcrusher, bits: 6, sample_rate: 0.4 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.08, release: 0.05,
                         pulse_width: 0.15, cutoff: 86,
                         amp: sec_for(t) == :sprint ? 0.5 : 0.42
      4.times do
        ARP_CHORDS.each { |chord| chord.each { |n| play note(n) + sh; sleep 0.5 } }
      end
    end
  end
end

# ── Oom-pah bass ──────────────────────────────────────────────────────────────
live_loop :bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  sh  = shift(t)
  with_fx :distortion, distort: 0.75 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.2, release: 0.08,
                       amp: sec == :verse ? 2.3 : 2.8
    2.times do
      BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
        r = note(root) + sh
        f = note(fifth) + sh
        if sec == :sprint
          # oom-pah-pah-pah — 8ths on the off
          play r;      sleep 1
          play r + 12; sleep 0.5
          play f;      sleep 0.5
          play r;      sleep 1
          play r + 12; sleep 0.5
          play f;      sleep 0.5
        else
          play r;      sleep 1
          play r + 12; sleep 1
          play f;      sleep 1
          play r + 12; sleep 1
        end
      end
    end
  end
end

# ── Kick — bd_tek ─────────────────────────────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :verse
    32.times { sample :bd_tek, amp: 2.5; sleep 1 }
  when :sprint
    64.times { |i| sample :bd_tek, amp: (i.even? ? 3.2 : 2.6); sleep 0.5 }
  else
    64.times { sample :bd_tek, amp: 3.0; sleep 0.5 }
  end
end

# ── Snare — polka "pah" on 2 and 4 ────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  amp_v = sec == :verse ? 2.3 : 2.8
  if sec == :sprint
    8.times do
      sleep 1
      sample :sn_dolf, amp: 3.0, rate: 1.1
      sleep 1
      sleep 0.75
      sample :sn_dolf, amp: 1.6, rate: 1.35
      sleep 0.25
      sample :sn_dolf, amp: 3.0, rate: 1.1
      sleep 1
    end
  else
    16.times { sleep 1; sample :sn_dolf, amp: amp_v, rate: 1.05; sleep 1 }
  end
end

# ── Hats — hat_tap ────────────────────────────────────────────────────────────
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :verse
    64.times { |i| sample :hat_tap, amp: (i.odd? ? 1.0 : 0.55), rate: 1.3; sleep 0.5 }
  else
    128.times { |i| sample :hat_tap, amp: (i % 4 == 0 ? 1.2 : 0.6), rate: 1.4; sleep 0.25 }
  end
end

# ── Modulation markers — a crash on every key change and every gear change ────
live_loop :marker, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sample(:drum_cymbal_open, amp: 0.85, finish: 0.5) if [2, 3, 4, 5, 7].include?(t)
  sleep 32
end
