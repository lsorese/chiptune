# polka.rb — jaunty chiptune polka, ~2 minutes
# 140 BPM  |  D major  |  D – A – G – D (jaunty I–V–IV–I)
#
# sec 0 — verse:    oom-pah bass, kick+snare polka beat, sparse lead
# sec 1 — chorus:   full melodic lead, busier hats, brighter
# sec 2 — verse 2:  oom-pah with counter-melody arp
# sec 3 — chorus 2: lead + arp together, peak energy
#
# run_file "/Users/logan/Projects/chiptune/set6/polka.rb"

use_bpm 185

SONG_END = 12

# ── Conductor ─────────────────────────────────────────────────────────────────
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  osc_send "localhost", 4559, "/sp/polka/section", t
  sleep t == 0 ? 16 : 32
end

# ── Lead — accordion-style pulse melody ───────────────────────────────────────
# Two 16-beat phrases per 32-beat section. Quarter/eighth jaunty rhythm.
VERSE_MEL = [
  [:d5, 1], [:fs5, 1], [:a5, 1], [:fs5, 1],     # D
  [:e5, 1], [:cs5, 1], [:e5, 2],                # A
  [:d5, 1], [:b4, 1], [:d5, 1], [:g4, 1],       # G
  [:fs4, 1], [:a4, 1], [:d5, 2],                # D
]

CHORUS_MEL = [
  [:a5, 0.5], [:fs5, 0.5], [:d5, 1], [:fs5, 1], [:a5, 1],         # D
  [:cs6, 0.5], [:a5, 0.5], [:e5, 1], [:a5, 1], [:cs5, 1],         # A
  [:b5, 0.5], [:g5, 0.5], [:d5, 1], [:g5, 1], [:b5, 1],           # G
  [:a5, 0.5], [:fs5, 0.5], [:d5, 1], [:fs5, 1], [:d5, 1],         # D
]

live_loop :lead, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  with_fx :bitcrusher, bits: 7, sample_rate: 0.5 do
    use_synth :pulse
    use_synth_defaults attack: 0.002, sustain: 0.1, release: 0.04,
                       pulse_width: 0.22, cutoff: 100, amp: 0.85
    if [0, 2].include?(sec)
      # sparse verse melody, played twice
      2.times do
        VERSE_MEL.each { |n, d| play n; sleep d }
      end
    else
      # busier chorus, played twice
      2.times do
        CHORUS_MEL.each { |n, d| play n; sleep d }
      end
    end
  end
end

# ── Counter-melody arp (chorus + verse 2) ─────────────────────────────────────
ARP_CHORDS = [
  [:d4,  :fs4, :a4,  :fs4],   # D
  [:cs4, :e4,  :a4,  :e4 ],   # A
  [:b3,  :d4,  :g4,  :d4 ],   # G
  [:a3,  :d4,  :fs4, :d4 ],   # D
]

live_loop :arp, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  if [1, 2, 3].include?(sec)
    with_fx :bitcrusher, bits: 6, sample_rate: 0.4 do
      use_synth :pulse
      use_synth_defaults attack: 0, sustain: 0.08, release: 0.05,
                         pulse_width: 0.15, cutoff: 86,
                         amp: sec == 2 ? 0.32 : 0.42
      4.times do
        ARP_CHORDS.each do |chord|
          chord.each { |n| play n; sleep 0.5 }
        end
      end
    end
  else
    sleep 32
  end
end

# ── Oom-pah bass ──────────────────────────────────────────────────────────────
# Beat 1: low root  |  Beat 2: higher root or fifth (the "pah")
# Each chord gets 4 beats (2 oom-pah pairs).
BASS_ROOTS  = [:d2, :a1, :g1, :d2]
BASS_FIFTHS = [:a2, :e2, :d2, :a2]

live_loop :bass, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  chorus = [1, 3].include?(sec)
  with_fx :distortion, distort: 0.75 do
    use_synth :chipbass
    use_synth_defaults attack: 0, sustain: 0.2, release: 0.08,
                       amp: chorus ? 2.8 : 2.3
    2.times do
      BASS_ROOTS.zip(BASS_FIFTHS).each do |root, fifth|
        # oom-pah-oom-pah over 4 beats
        play root;       sleep 1
        play root + 12;  sleep 1
        play fifth;      sleep 1
        play root + 12;  sleep 1
      end
    end
  end
end

# ── Kick — downbeats (polka stomp) ────────────────────────────────────────────
live_loop :kick, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  chorus = [1, 3].include?(sec)
  amp = chorus ? 3.0 : 2.5
  if chorus
    # driving double-kick — 8th notes
    64.times { sample :bd_haus, amp: amp; sleep 0.5 }
  else
    # punchy polka: kick on every beat
    32.times { sample :bd_haus, amp: amp; sleep 1 }
  end
end

# ── Snare — backbeat / polka "pah" ────────────────────────────────────────────
live_loop :snare, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  chorus = [1, 3].include?(sec)
  16.times do
    sleep 1
    sample :sn_dolf, amp: chorus ? 2.8 : 2.3, rate: 1.05
    sleep 1
  end
end

# ── Hats — bouncy offbeats ────────────────────────────────────────────────────
live_loop :hats, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  sec = (t / 2) % 4
  chorus = [1, 3].include?(sec)
  if chorus
    # 16th-note hats — frantic
    128.times do |i|
      sample :hat_snap, amp: (i % 4 == 0 ? 1.2 : 0.6), rate: 1.4
      sleep 0.25
    end
  else
    # 8th-note hats with offbeat accents
    64.times do |i|
      sample :hat_snap, amp: (i.odd? ? 1.0 : 0.55), rate: 1.3
      sleep 0.5
    end
  end
end
