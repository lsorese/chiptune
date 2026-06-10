# final.rb — set6: +20% length — t=8,9 forced to sec 3 (extended outro/choir fade)
# 70 BPM  |  A minor  |  Am – F – C – G
#
# sec 0 — sparse verse:  whole-note bass, beat 1 kick, snare on 3, no hats, slow arp
# sec 1 — full verse:    bouncy bass, 4-on-floor kick, ska hats, snare 2+4, arp
# sec 2 — heavy chorus:  gallop bass, double kick, 16th hats, stabs
# sec 3 — outro:         whole-note bass, beat 1 kick only, crash, arp with long echo
# (t=8,9 extend the outro — choir swells longer, echo arp plays two more passes)
#
# run_file "/Users/logan/Projects/chiptune/set6/7. final.rb"

use_bpm 70

SONG_END = 10

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  osc_send "localhost", 4559, "/sp/final/section", t
  sleep t == 0 ? 16 : 32
end

# ── Slow ascending arp (sec 0, 1, 3) ──────────────────────────────────────────
ARP_UP = [
  [:a3, :c4, :e4, :a4, :e4, :c4, :a3, :c4],   # Am
  [:f3, :a3, :c4, :f4, :c4, :a3, :f3, :a3],   # F
  [:c3, :e3, :g3, :c4, :g3, :e3, :c3, :e3],   # C
  [:g3, :b3, :d4, :g4, :d4, :b3, :g3, :b3],   # G
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = t >= 8 ? 3 : (t / 2) % 4
  if sec == 0
    with_fx :bitcrusher, bits: 8, sample_rate: 0.5 do
      with_fx :reverb, room: 0.5, mix: 0.12 do
        use_synth :pulse
        use_synth_defaults attack: 0.05, sustain: 1.7, release: 0.3,
                           amp: 0.45, pulse_width: 0.22, cutoff: 80
        ARP_UP[0..1].each do |chord|
          chord.each { |n| play n; sleep 2 }
        end
      end
    end
  elsif sec != 2
    reverb_mix = sec == 3 ? 0.35 : 0.12
    with_fx :bitcrusher, bits: 8, sample_rate: 0.5 do
      with_fx :reverb, room: 0.5, mix: reverb_mix do
        use_synth :pulse
        use_synth_defaults attack: 0.05, sustain: 0.82, release: 0.15,
                           amp: 0.45, pulse_width: 0.22, cutoff: 80
        ARP_UP.each do |chord|
          chord.each { |n| play n; sleep 1 }
        end
      end
    end
  else
    sleep 32
  end
end

# ── Descending stabs (chorus only) ────────────────────────────────────────────
STABS_DOWN = [
  [:a5, :e5, :c5, :a4, :e4, :c4, :e4, :a4],   # Am
  [:f5, :c5, :a4, :f4, :c4, :a3, :c4, :f4],   # F
  [:c5, :g4, :e4, :c4, :g3, :e3, :g3, :c4],   # C
  [:g5, :d5, :b4, :g4, :d4, :b3, :d4, :g4],   # G
]

live_loop :stabs, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = t >= 8 ? 3 : (t / 2) % 4
  if sec == 2
    with_fx :bitcrusher, bits: 6, sample_rate: 0.4 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.08, release: 0.06,
                         amp: 0.6, pulse_width: 0.15, cutoff: 100
      2.times do
        STABS_DOWN.each do |pattern|
          pattern.each { |n| play n; sleep 0.25 }
          sleep 2
        end
      end
    end
  else
    sleep 32
  end
end

# ── Chip bass ─────────────────────────────────────────────────────────────────
BASS_ROOTS  = [:a1, :f2, :c2, :g1]
BASS_FIFTHS = [:e2, :c3, :g2, :d2]

live_loop :chip_bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = t >= 8 ? 3 : (t / 2) % 4
  with_fx :distortion, distort: 0.55 do
    use_synth :chipbass
    case sec
    when 0, 3
      use_synth_defaults attack: 0, sustain: 3.5, release: 0.8, amp: 2.2
      2.times do
        BASS_ROOTS.each { |r| play r; sleep 4 }
      end
    when 1
      use_synth_defaults attack: 0, sustain: 0.2, release: 0.08, amp: 2.0
      2.times do
        BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
          play root;      sleep 1
          play root + 12; sleep 1
          play fifth;     sleep 1
          play root + 12; sleep 1
        end
      end
    when 2
      use_synth_defaults attack: 0, sustain: 0.12, release: 0.04, amp: 2.4
      2.times do
        BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
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

# ── Kick ──────────────────────────────────────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = t >= 8 ? 3 : (t / 2) % 4
  case sec
  when 0, 3
    8.times do
      sample :bd_haus, amp: 2.0; sleep 4
    end
  when 1
    32.times do
      sample :bd_haus, amp: 2.0; sleep 1
    end
  when 2
    8.times do
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
      sample :bd_haus, amp: 2.2; sleep 0.25
      sample :bd_haus, amp: 1.8; sleep 0.75
      sleep 1
    end
  end
end

# ── Snare ─────────────────────────────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = t >= 8 ? 3 : (t / 2) % 4
  case sec
  when 0
    8.times do
      sleep 2
      sample :sn_dolf, amp: 2.0, rate: 0.85
      sleep 2
    end
  when 1
    8.times do
      sleep 1
      sample :sn_dolf, amp: 1.8, rate: 1.0
      sleep 2
      sample :sn_dolf, amp: 2.0, rate: 1.0
      sleep 1
    end
  when 2
    8.times do
      sleep 1
      sample :sn_dolf, amp: 2.4, rate: 0.88
      sleep 2
      sample :sn_dolf, amp: 2.6, rate: 0.85
      sleep 1
    end
  when 3
    sleep 32
  end
end

# ── Hats ──────────────────────────────────────────────────────────────────────
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = t >= 8 ? 3 : (t / 2) % 4
  case sec
  when 0, 3
    sleep 32
  when 1
    64.times do |i|
      sample :hat_snap, amp: 0.8, rate: 1.1 if i.odd?
      sleep 0.5
    end
  when 2
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 0.9 : 0.45), rate: 1.3
      sleep 0.25
    end
  end
end

# ── Crash (outro resolution) ──────────────────────────────────────────────────
live_loop :crash, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = t >= 8 ? 3 : (t / 2) % 4
  if sec == 3
    8.times do
      sample :drum_cymbal_open, amp: 0.6, finish: 0.6
      sleep 4
    end
  else
    sleep 32
  end
end

# ── Texture — glitch_perc1 chorus accent + ambi_choir extended outro ──────────
GPERC_FN = "/Users/logan/Projects/chiptune/samples/drums/one-shots/glitchy/glitch_perc1.flac"
ACHOIR_FN = "/Users/logan/Projects/chiptune/samples/ambient/ambi_choir.flac"

live_loop :texture, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = t >= 8 ? 3 : (t / 2) % 4
  case sec
  when 2
    8.times do
      sample GPERC_FN, amp: 0.35, rate: rrand(0.9, 1.1)
      sleep 4
    end
  when 3
    sample ACHOIR_FN, amp: 0.28, attack: 4.0, release: 6.0
    sleep 32
  else
    sleep 32
  end
end

# ── Coda — final G chord, held indefinitely ───────────────────────────────────
# fires once at t=SONG_END after all other loops stop, then rings out
live_loop :coda, sync: :conductor do
  t = tick
  if t == SONG_END
    with_fx :reverb, room: 0.95, mix: 0.70 do
      use_synth :chipbass
      play :g1, sustain: 300.0, release: 60.0, amp: 2.0, cutoff: 68
      play :g2, sustain: 300.0, release: 60.0, amp: 1.2, cutoff: 72
      use_synth :pulse
      [[:g3, 0.22, -0.3], [:b3, 0.18, 0.3], [:d4, 0.20, 0.0]].each do |n, pw, pan|
        play n, sustain: 300.0, release: 60.0, amp: 0.42,
                pulse_width: pw, cutoff: 75, attack: 1.0, pan: pan
      end
    end
    stop
  else
    sleep 32
  end
end
