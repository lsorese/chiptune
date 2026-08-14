# 4. disco.rb — set7: NOISE BLAST, now with a half-speed trapdoor
# 240 BPM → 120 BPM sludge → 260 BPM nuclear  |  B → G → C
#
# Identity: the loudest thing in the set. Full noise wall, 4-bit crushed saw
# power chords, blast beat. What's new is the floor dropping out at t=3 —
# everything halves in speed and the key slides to G — then it fires back up
# a semitone above where it started.
#
# t=0   blast    @240  B  — blast beat, rapid B1 bass, riff
# t=1   disco    @240  B  — octave-pump disco breakdown
# t=2   glitch   @240  B  — blast + glitch layer
# t=3   SLUDGE   @120  G  — half speed, C/D power chords, everything crawls
# t=4   nuclear  @260  C  — modulation, maximum amp
# t=5   disco    @260  C  — disco pump at the new tempo, hard stop
#
# run_file "/Users/logan/Projects/chiptune/set7/4. disco.rb"

use_bpm 240

SONG_END = 6

GNOISE_GR = "/Users/logan/Projects/chiptune/samples/noise loops/rand-stream-dark-pink.wav"
GPERCS_GR = [
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc2.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc3.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc4.flac",
  "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc5.flac",
]

def bpm_for(t)
  case t
  when 3    then 120
  when 4, 5 then 260
  else           240
  end
end

def sec_for(t)
  case t
  when 0    then :blast
  when 1    then :disco
  when 2    then :glitch
  when 3    then :sludge
  when 4    then :nuclear
  else           :disco2
  end
end

# ── Power-chord roots per key region ──────────────────────────────────────────
B_ROOTS = [:b1,  :e2,  :a1,  :fs2]
B_LEAD  = [:b3,  :e3,  :a3,  :fs3]
G_ROOTS = [:g1,  :c2,  :d2,  :g1 ]
G_LEAD  = [:g3,  :c4,  :d4,  :g3 ]
C_ROOTS = [:c2,  :f2,  :g2,  :bb1]
C_LEAD  = [:c4,  :f3,  :g3,  :bb3]

def roots(t)
  return G_ROOTS if t == 3
  t >= 4 ? C_ROOTS : B_ROOTS
end

def leads(t)
  return G_LEAD if t == 3
  t >= 4 ? C_LEAD : B_LEAD
end

def tonic(t)
  roots(t).first
end

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  use_bpm bpm_for(t.zero? ? 0 : t - 1)
  osc_send "localhost", 4559, "/sp/disco/section", t
  sleep t.zero? ? 16 : 32
end

# ── Drums ─────────────────────────────────────────────────────────────────────
live_loop :drums, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :disco, :disco2
    hot = t >= 4
    8.times do
      sample :bd_klub, amp: hot ? 3.6 : 3.2;                sleep 1
      sample :bd_klub, amp: hot ? 3.2 : 2.8;                sleep 0.5
      sample :bd_klub, amp: hot ? 3.2 : 2.8;                sleep 0.5
      sample :sn_dolf, amp: hot ? 3.8 : 3.4, rate: 0.75;    sleep 2
    end

  when :sludge
    # half speed AND half density — the trapdoor
    8.times do
      sample :bd_klub, amp: 3.8;                sleep 2
      sample :sn_dolf, amp: 3.4, rate: 0.6;     sleep 1
      sample :bd_klub, amp: 2.6;                sleep 1
    end

  else # :blast / :glitch / :nuclear
    amp_v = t >= 4 ? 3.4 : 2.8
    128.times do |i|
      sample :bd_klub, amp: amp_v
      sample(:sn_dolf, amp: amp_v - 0.5, rate: 0.90) if i.odd?
      sleep 0.25
    end
  end
end

# ── Bass ──────────────────────────────────────────────────────────────────────
live_loop :bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  hot = t >= 4
  case sec
  when :disco, :disco2
    with_fx :distortion, distort: hot ? 0.70 : 0.55 do
      use_synth :chipbass
      use_synth_defaults attack: 0, sustain: 0.35, release: 0.1, amp: hot ? 3.8 : 3.2
      8.times do
        r = tonic(t)
        play r;             sleep 0.5
        play r + 12;        sleep 0.5
        play roots(t)[3];   sleep 0.5
        play r + 12;        sleep 0.5
        play r;             sleep 0.5
        play r + 12;        sleep 0.5
        play roots(t)[1];   sleep 0.5
        play roots(t)[2];   sleep 0.5
      end
    end

  when :sludge
    with_fx :distortion, distort: 0.95 do
      with_fx :bitcrusher, bits: 3, sample_rate: 0.15 do
        use_synth :chipbass
        use_synth_defaults attack: 0, sustain: 1.7, release: 0.4, amp: 3.6
        2.times { roots(t).each { |r| play r; sleep 4 } }
      end
    end

  else
    with_fx :distortion, distort: hot ? 0.97 : 0.92 do
      with_fx :bitcrusher, bits: 4, sample_rate: 0.25 do
        use_synth :chipbass
        use_synth_defaults attack: 0, sustain: 0.1, release: 0.03, amp: hot ? 3.4 : 2.8
        128.times { play tonic(t); sleep 0.25 }
      end
    end
  end
end

# ── Lead — 4-bit crushed saw power chords ─────────────────────────────────────
live_loop :lead, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  hot = t >= 4
  with_fx :distortion, distort: 0.97 do
    with_fx :bitcrusher, bits: 4, sample_rate: 0.18 do
      use_synth :saw
      case sec
      when :disco, :disco2
        use_synth_defaults attack: 0.02, sustain: 1.7, release: 0.3,
                           amp: hot ? 1.5 : 1.2, cutoff: 125
        8.times do
          play leads(t)[0]; play leads(t)[0] + 7; sleep 2
          play leads(t)[1]; play leads(t)[1] + 7; sleep 2
        end

      when :sludge
        use_synth_defaults attack: 0.05, sustain: 3.4, release: 0.6,
                           amp: 1.6, cutoff: 100
        2.times do
          leads(t).each do |l|
            play l; play l + 7; play l - 12
            sleep 4
          end
        end

      else
        use_synth_defaults attack: 0, sustain: 0.12, release: 0.04,
                           amp: hot ? 1.4 : 1.0, cutoff: 128
        2.times do
          leads(t).each do |l|
            4.times do
              play l; play l + 7; sleep 0.5
              play l; play l + 7; sleep 0.25
              play l; play l + 7; sleep 0.25
            end
          end
        end
      end
    end
  end
end

# ── Noise wall ────────────────────────────────────────────────────────────────
live_loop :noise_wall, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  with_fx :distortion, distort: 0.99 do
    with_fx :bitcrusher, bits: 3, sample_rate: 0.12 do
      use_synth :noise
      cut = case sec
            when :disco, :disco2 then 78
            when :sludge         then 62
            else                      108
            end
      play :a3, sustain: 30, release: 2,
           amp: sec == :sludge ? 0.85 : (t >= 4 ? 0.7 : 0.5),
           cutoff: cut
    end
  end
  sleep 32
end

# ── Glitch layer ──────────────────────────────────────────────────────────────
live_loop :glitch, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :glitch
    sample GNOISE_GR, amp: 0.4, attack: 0.5, release: 4.0
    64.times do
      sample(GPERCS_GR.choose, amp: rrand(0.6, 1.2), rate: rrand(0.4, 2.2)) if one_in(2)
      sleep 0.5
    end
  when :sludge
    # slow, huge, sparse glitch hits
    sample GNOISE_GR, amp: 0.55, rate: 0.5, attack: 1.0, release: 6.0
    16.times do
      sample(GPERCS_GR.choose, amp: rrand(1.0, 1.8), rate: rrand(0.2, 0.7)) if one_in(2)
      sleep 2
    end
  when :nuclear
    sample GNOISE_GR, amp: 0.7, attack: 0.2, release: 4.0
    64.times do
      sample(GPERCS_GR.choose, amp: rrand(0.9, 2.0), rate: rrand(0.4, 2.6)) if one_in(2)
      sleep 0.5
    end
  else
    sleep 32
  end
end
