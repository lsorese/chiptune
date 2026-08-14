# 7. wire.rb — set7: BREAKBEAT / JUNGLE CHIPTUNE
# 164 BPM → 88 BPM dub skank → 172 BPM meltdown → 164 BPM
# G# minor → B minor modulation
#
# Identity: the only chopped breakbeat in the set — no 4-on-the-floor anywhere.
# bd_klub / sn_dub / hat_zan plus toms, and the ring-mod arp that only this
# track uses. The skank section is the set's only reggae feel.
#
# t=0    break     @164  G#m — breakbeat, walk bass, ring-mod arp
# t=1    break     @164  G#m — + chaos stabs
# t=2    SKANK     @88   G#m — half-time dub skank, offbeat chords, no arp
# t=3,4  MELTDOWN  @172  Bm  — modulation, break doubles, ring mod cranked
# t=5    break     @164  G#m — home key, cooling
# t=6    outro     @164  G#m — arp alone over sparse break
#
# run_file "/Users/logan/Projects/chiptune/set7/7. wire.rb"

use_bpm 164

SONG_END = 7

def bpm_for(t)
  case t
  when 2    then 88
  when 3, 4 then 172
  else           164
  end
end

def sec_for(t)
  case t
  when 0    then :break1
  when 1    then :break2
  when 2    then :skank
  when 3, 4 then :meltdown
  when 5    then :cool
  else           :outro
  end
end

def melting?(t)
  [3, 4].include?(t)
end

# ── Progressions ──────────────────────────────────────────────────────────────
GS_ROOTS  = [:gs2, :e2,  :b1,  :fs2]
GS_WALK   = [:b2,  :gs2, :ds2, :as2]
GS_ARP    = [[:gs4, :b4,  :ds5, :gs5, :ds5, :b4,  :gs4, :ds4],   # G#m
             [:e4,  :gs4, :b4,  :e5,  :b4,  :gs4, :e4,  :b3 ],   # E
             [:b3,  :ds4, :fs4, :b4,  :fs4, :ds4, :b3,  :fs3],   # B
             [:fs4, :as4, :cs5, :fs5, :cs5, :as4, :fs4, :cs4]]   # F#
GS_CHORDS = [[:gs3, :b3, :ds4], [:e3, :gs3, :b3], [:b3, :ds4, :fs4], [:fs3, :as3, :cs4]]

BM_ROOTS  = [:b1,  :g1,  :d2,  :a1 ]
BM_WALK   = [:d2,  :b1,  :fs2, :cs2]
BM_ARP    = [[:b4,  :d5,  :fs5, :b5,  :fs5, :d5,  :b4,  :fs4],   # Bm
             [:g4,  :b4,  :d5,  :g5,  :d5,  :b4,  :g4,  :d4 ],   # G
             [:d4,  :fs4, :a4,  :d5,  :a4,  :fs4, :d4,  :a3 ],   # D
             [:a4,  :cs5, :e5,  :a5,  :e5,  :cs5, :a4,  :e4 ]]   # A
BM_CHORDS = [[:b3, :d4, :fs4], [:g3, :b3, :d4], [:d4, :fs4, :a4], [:a3, :cs4, :e4]]

def roots(t);   melting?(t) ? BM_ROOTS  : GS_ROOTS  end
def walks(t);   melting?(t) ? BM_WALK   : GS_WALK   end
def arps(t);    melting?(t) ? BM_ARP    : GS_ARP    end
def chords(t);  melting?(t) ? BM_CHORDS : GS_CHORDS end

# ── The break — 32 sixteenths = 8 beats ───────────────────────────────────────
BREAK = [:k, :r, :r, :k,  :r, :r, :s, :r,  :r, :r, :k, :r,  :r, :s, :r, :r,
         :k, :r, :r, :k,  :r, :r, :s, :r,  :r, :r, :k, :r,  :s, :r, :s, :r]

SPARSE = [:k, :r, :r, :r,  :r, :r, :s, :r,  :r, :r, :k, :r,  :r, :s, :r, :r,
          :k, :r, :r, :r,  :r, :r, :s, :r,  :r, :r, :r, :r,  :s, :r, :r, :r]

def play_break(pattern, kamp, samp, hat)
  pattern.each_with_index do |step, i|
    case step
    when :k then sample :bd_klub, amp: kamp
    when :s then sample :sn_dub,  amp: samp, rate: (i > 24 ? 1.15 : 1.0)
    end
    sample(hat, amp: (i % 4 == 0 ? 0.7 : 0.35), rate: 1.3) if hat
    sleep 0.25
  end
end

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  use_bpm bpm_for(t.zero? ? 0 : t - 1)
  osc_send "localhost", 4559, "/sp/wire/section", t
  sleep t.zero? ? 16 : 32
end

# ── Drums ─────────────────────────────────────────────────────────────────────
live_loop :drums, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :skank
    # one-drop: kick and snare together on beat 3, hat on every offbeat
    8.times do
      sample :hat_zan, amp: 0.45, rate: 1.0
      sleep 1
      sample :hat_zan, amp: 0.7, rate: 1.0
      sleep 1
      sample :bd_klub, amp: 2.6
      sample :sn_dub,  amp: 2.4, rate: 0.85
      sample :hat_zan, amp: 0.45, rate: 1.0
      sleep 1
      sample :hat_zan, amp: 0.7, rate: 1.0
      sleep 1
    end

  when :meltdown
    # double-time break plus tom fills at the end of each phrase
    3.times { play_break BREAK, 2.3, 2.5, :hat_zan }
    play_break BREAK[0..15], 2.3, 2.5, :hat_zan
    [:drum_tom_hi_hard, :drum_tom_mid_hard, :drum_tom_lo_hard].each do |tom|
      2.times { sample tom, amp: 1.6; sleep 0.5 }
    end
    sample :drum_cymbal_open, amp: 1.0, finish: 0.4
    sleep 1

  when :outro
    4.times { play_break SPARSE, 1.9, 2.0, nil }

  else
    4.times { play_break BREAK, 2.1, 2.3, :hat_zan }
  end
end

# ── Ring-mod arp — wire's signature ───────────────────────────────────────────
live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  if sec == :skank
    sleep 32
  else
    ring_freq = sec == :meltdown ? 440 : 180
    ring_mix  = sec == :meltdown ? 0.65 : 0.28
    bits_val  = sec == :meltdown ? 5    : 7
    amp_v     = sec == :outro ? 0.55 : 0.4
    with_fx :ring_mod, freq: ring_freq, mix: ring_mix do
      with_fx :bitcrusher, bits: bits_val, sample_rate: 0.45 do
        use_synth :pulse
        use_synth_defaults attack: 0, sustain: 0.1, release: 0.08,
                           amp: amp_v, pulse_width: 0.18, cutoff: 88
        2.times do
          arps(t).each { |chord| chord.each { |n| play n; sleep 0.5 } }
        end
      end
    end
  end
end

# ── Skank chords — offbeat, heavily damped ────────────────────────────────────
live_loop :skank, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  if sec_for(t) == :skank
    with_fx :echo, phase: 0.75, decay: 6, mix: 0.4 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.06, release: 0.12,
                         pulse_width: 0.4, cutoff: 92, amp: 0.7
      2.times do
        chords(t).each do |chord|
          4.times do
            sleep 0.5
            play chord
            sleep 0.5
          end
        end
      end
    end
  else
    sleep 32
  end
end

# ── Bass ──────────────────────────────────────────────────────────────────────
live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  with_fx :distortion, distort: sec == :skank ? 0.2 : 0.6 do
    use_synth :chipbass
    case sec
    when :skank
      # fat dub bassline — long notes, huge gaps
      use_synth_defaults attack: 0.01, sustain: 1.4, release: 0.4, amp: 2.6, cutoff: 66
      2.times do
        roots(t).zip(walks(t)).each do |root, walk|
          play root - 12; sleep 1.5
          play walk - 12; sleep 0.5
          sleep 1
          play root - 12; sleep 1
        end
      end

    when :meltdown
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.04, amp: 2.4
      2.times do
        roots(t).zip(walks(t)).each do |root, walk|
          4.times do
            play root;  sleep 0.5
            play root;  sleep 0.25
            play walk;  sleep 0.25
          end
        end
      end

    when :outro
      use_synth_defaults attack: 0, sustain: 1.6, release: 0.3, amp: 2.0
      2.times { roots(t).each { |r| play r; sleep 2; play r + 12; sleep 2 } }

    else
      use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: 1.7
      2.times do
        roots(t).zip(walks(t)).each do |root, walk|
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
end

# ── Texture ───────────────────────────────────────────────────────────────────
ASWOOSH_W = "/Users/logan/Projects/chiptune/samples/ambient/ambi_swoosh.flac"
GPERC_W   = "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac"

live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :skank
    sample ASWOOSH_W, amp: 0.3, rate: 0.6, attack: 2.0, release: 6.0
    sleep 32
  when :meltdown
    8.times { sample GPERC_W, amp: 0.5, rate: rrand(0.8, 1.4); sleep 4 }
  else
    sleep 32
  end
end
