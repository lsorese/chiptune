# 9. final.rb — set7: THE CLOSER
# 60 → 70 → 88 → 96 → 56 BPM  |  A minor, choruses modulate to D minor,
# coda resolves to A MAJOR (picardy third — the set's only major resolution)
#
# Identity: the only track that breathes. Slow :pulse arp with long reverb,
# bd_sone / sn_dub / hat_tap, and a held final chord.
#
# t=0  sparse   @60  Am — whole-note bass, beat 1 kick, half-speed arp
# t=1  verse    @70  Am — bouncy bass, 4-on-floor, ska hats
# t=2  chorus   @88  Dm — modulation, gallop bass, stabs, 16th hats
# t=3  verse    @70  Am — back home, quieter
# t=4  chorus   @88  Dm — bigger
# t=5  CLIMAX   @96  Dm — fastest and loudest point of the track
# t=6  outro    @56  Am — everything falls away, crash, choir
# coda           —   A  — held A major chord, rings out
#
# run_file "/Users/logan/Projects/chiptune/set7/9. final.rb"

use_bpm 60

SONG_END = 7

def bpm_for(t)
  case t
  when 0    then 60
  when 1, 3 then 70
  when 2, 4 then 88
  when 5    then 96
  else           56
  end
end

def sec_for(t)
  case t
  when 0    then :sparse
  when 1, 3 then :verse
  when 2, 4 then :chorus
  when 5    then :climax
  else           :outro
  end
end

def in_dm(t)
  [2, 4, 5].include?(t)
end

# ── Progressions ──────────────────────────────────────────────────────────────
AM_ROOTS  = [:a1, :f2, :c2, :g1]
AM_FIFTHS = [:e2, :c3, :g2, :d2]
AM_ARP    = [[:a3, :c4, :e4, :a4, :e4, :c4, :a3, :c4],   # Am
             [:f3, :a3, :c4, :f4, :c4, :a3, :f3, :a3],   # F
             [:c3, :e3, :g3, :c4, :g3, :e3, :c3, :e3],   # C
             [:g3, :b3, :d4, :g4, :d4, :b3, :g3, :b3]]   # G

DM_ROOTS  = [:d2, :bb1, :f2, :c2]
DM_FIFTHS = [:a2, :f2,  :c3, :g2]
DM_STABS  = [[:d5, :a4,  :f4, :d4, :a3, :f3, :a3, :d4],   # Dm
             [:bb4, :f4, :d4, :bb3, :f3, :d3, :f3, :bb3], # Bb
             [:f5, :c5,  :a4, :f4, :c4, :a3, :c4, :f4],   # F
             [:c5, :g4,  :e4, :c4, :g3, :e3, :g3, :c4]]   # C

def roots(t);  in_dm(t) ? DM_ROOTS  : AM_ROOTS  end
def fifths(t); in_dm(t) ? DM_FIFTHS : AM_FIFTHS end

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  use_bpm bpm_for(t.zero? ? 0 : t - 1)
  osc_send "localhost", 4559, "/sp/final/section", t
  sleep t.zero? ? 16 : 32
end

# ── Arp ───────────────────────────────────────────────────────────────────────
live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  case sec
  when :sparse
    with_fx :bitcrusher, bits: 8, sample_rate: 0.5 do
      with_fx :reverb, room: 0.5, mix: 0.15 do
        use_synth :pulse
        use_synth_defaults attack: 0.05, sustain: 1.7, release: 0.3,
                           amp: 0.45, pulse_width: 0.22, cutoff: 80
        AM_ARP[0..1].each { |chord| chord.each { |n| play n; sleep 2 } }
      end
    end

  when :verse
    with_fx :bitcrusher, bits: 8, sample_rate: 0.5 do
      with_fx :reverb, room: 0.5, mix: 0.12 do
        use_synth :pulse
        use_synth_defaults attack: 0.05, sustain: 0.82, release: 0.15,
                           amp: 0.45, pulse_width: 0.22, cutoff: 80
        AM_ARP.each { |chord| chord.each { |n| play n; sleep 1 } }
      end
    end

  when :outro
    with_fx :bitcrusher, bits: 8, sample_rate: 0.5 do
      with_fx :reverb, room: 0.8, mix: 0.45 do
        use_synth :pulse
        use_synth_defaults attack: 0.1, sustain: 1.6, release: 0.5,
                           amp: 0.5, pulse_width: 0.22, cutoff: 76
        AM_ARP.each { |chord| chord[0..3].each { |n| play n; sleep 2 } }
      end
    end

  else
    sleep 32
  end
end

# ── Stabs (chorus + climax, in D minor) ───────────────────────────────────────
live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  sec = sec_for(t)
  if [:chorus, :climax].include?(sec)
    with_fx :bitcrusher, bits: 6, sample_rate: 0.4 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.08, release: 0.06,
                         amp: sec == :climax ? 0.75 : 0.6,
                         pulse_width: 0.15, cutoff: 100
      2.times do
        DM_STABS.each do |pattern|
          pattern.each { |n| play n; sleep 0.25 }
          sleep 2
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
  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    case sec_for(t)
    when :sparse, :outro
      use_synth_defaults attack: 0, sustain: 3.5, release: 0.8, amp: 2.2
      2.times { roots(t).each { |r| play r; sleep 4 } }

    when :verse
      use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: 2.0
      2.times do
        roots(t).zip(fifths(t)).each do |root, fifth|
          play root;      sleep 1
          play root + 12; sleep 1
          play fifth;     sleep 1
          play root + 12; sleep 1
        end
      end

    else # :chorus / :climax
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.04,
                         amp: sec_for(t) == :climax ? 2.6 : 2.4
      2.times do
        roots(t).zip(fifths(t)).each do |root, fifth|
          4.times do
            play root;  sleep 0.5
            play root;  sleep 0.25
            play fifth; sleep 0.25
          end
        end
      end
    end
  end
end

# ── Kick — bd_sone ────────────────────────────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :sparse, :outro
    8.times { sample :bd_sone, amp: 2.2; sleep 4 }
  when :verse
    32.times { sample :bd_sone, amp: 2.0; sleep 1 }
  when :climax
    64.times { sample :bd_sone, amp: 2.4; sleep 0.5 }
  else
    8.times do
      sample :bd_sone, amp: 2.2; sleep 0.25
      sample :bd_sone, amp: 1.8; sleep 0.75
      sleep 1
      sample :bd_sone, amp: 2.2; sleep 0.25
      sample :bd_sone, amp: 1.8; sleep 0.75
      sleep 1
    end
  end
end

# ── Snare — sn_dub ────────────────────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :sparse
    8.times { sleep 2; sample :sn_dub, amp: 2.0, rate: 0.85; sleep 2 }
  when :outro
    sleep 32
  when :verse
    8.times do
      sleep 1
      sample :sn_dub, amp: 1.8, rate: 1.0
      sleep 2
      sample :sn_dub, amp: 2.0, rate: 1.0
      sleep 1
    end
  else
    8.times do
      sleep 1
      sample :sn_dub, amp: 2.4, rate: 0.95
      sleep 2
      sample :sn_dub, amp: 2.6, rate: 0.9
      sleep 1
    end
  end
end

# ── Hats — hat_tap ────────────────────────────────────────────────────────────
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :sparse, :outro
    sleep 32
  when :verse
    64.times { |i| sample(:hat_tap, amp: 0.8, rate: 1.1) if i.odd?; sleep 0.5 }
  when :climax
    128.times { |i| sample :hat_tap, amp: (i % 4 == 0 ? 1.0 : 0.5), rate: 1.4; sleep 0.25 }
  else
    128.times { |i| sample :hat_tap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.3; sleep 0.25 }
  end
end

# ── Crash + texture ───────────────────────────────────────────────────────────
GPERC_FN  = "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac"
ACHOIR_FN = "/Users/logan/Projects/chiptune/samples/ambient/ambi_choir.flac"

live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)
  case sec_for(t)
  when :chorus, :climax
    8.times { sample GPERC_FN, amp: 0.35, rate: rrand(0.9, 1.1); sleep 4 }
  when :outro
    sample ACHOIR_FN, amp: 0.3, attack: 4.0, release: 8.0
    8.times { sample :drum_cymbal_open, amp: 0.6, finish: 0.6; sleep 4 }
  else
    sleep 32
  end
end

# ── Coda — held A MAJOR, the set's only major resolution ──────────────────────
live_loop :coda, sync: :conductor do
  t = tick
  use_bpm bpm_for(SONG_END - 1)
  if t == SONG_END
    with_fx :reverb, room: 0.95, mix: 0.70 do
      use_synth :chipbass
      play :a1, sustain: 160.0, release: 40.0, amp: 2.0, cutoff: 68
      play :a2, sustain: 160.0, release: 40.0, amp: 1.2, cutoff: 72
      use_synth :pulse
      [[:a3, 0.22, -0.3], [:cs4, 0.18, 0.3], [:e4, 0.20, 0.0]].each do |n, pw, pan|
        play n, sustain: 160.0, release: 40.0, amp: 0.42,
                pulse_width: pw, cutoff: 75, attack: 1.5, pan: pan
      end
    end
    stop
  else
    sleep 32
  end
end
