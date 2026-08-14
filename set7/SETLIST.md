# Set 7 — Setlist

**Total runtime: ~25 minutes** (set 6 was ~35 — 29% shorter)

Every track except the intro and the cover now changes tempo at least once
mid-song, and every track modulates to a new key at least once.

| # | Name | BPM (in order) | Keys | Duration |
|---|------|----------------|------|----------|
| 0 | **intro** | 60 | Am | ~48s |
| 1 | **fault** — hardcore punk | 175 → **200** | Bm → **Dm** | ~89s |
| — | *Static March* | 160 | B drone | ~72s |
| 2 | **edge** — half-time crusher | 148 → **100** → **168** | Cm → Cm/Gb → **Fm** | ~100s |
| — | *Half-Time Gallop* | 140 | Em drone | ~96s |
| 3 | **void** — doom dirge | 88 → 118 → **158** → 88 | Ebm → **Bbm** → Ebm | ~111s |
| — | *Doom March* | 120 | Ab drone | ~48s |
| 4 | **disco** — noise blast | 240 → **120** → **260** | B → **G** → **C** | ~59s |
| 5 | **polka** — accelerando | 170→185→200→210→**225** | D → **G** → **E** | ~85s |
| — | *Pressure Drop* | 200 | Bb drone | ~86s |
| 6 | **coil** — acid techno | 160 → **128** → **172** → 160 | F#m7 → **Am7** → F#m7 | ~91s |
| — | *Broken Machine* | 162 | F# drone | ~130s |
| 7 | **wire** — breakbeat/jungle | 164 → **88** → **172** → 164 | G#m → **Bm** → G#m | ~97s |
| 8 | **lightsaber** *(cover)* | 185 | — | ~119s |
| 9 | **final** — the closer | 60→70→88→96→**56** | Am → **Dm** → **A major** | ~201s + 60s coda |

## What changed from set 6

**Shorter.** ~35 min → ~25 min. Section counts cut on every track; the closer's
held coda halved; every interlude trimmed. The cover is untouched.

**De-cloned.** In set 6, tracks 1, 2, 3, 7 and 9 were structurally the same
song: identical 8-note `ARP_UP`, identical `STABS_DOWN`, identical gallop bass,
identical `bd_haus`/`sn_dolf`/`hat_snap` kit. Each now has its own instrument
set and its own rhythmic idea:

| Track | Kit | Lead voice | Rhythmic identity |
|-------|-----|-----------|-------------------|
| fault | bd_haus / sn_dolf / hat_snap | `:saw` power chords | straight punk, no arps |
| edge | bd_fat / sn_dub / hat_metal | `:dsaw` dyads + `:tri` sub | sits behind the beat |
| void | bd_boom / sn_zome / hat_bdu | `:prophet` pad + `:hollow` | tolls rather than arpeggiates |
| disco | bd_klub / sn_dolf | 4-bit `:saw` + noise wall | blast beat |
| polka | bd_tek / sn_dolf / hat_tap | `:pulse` accordion | oom-pah, only major key |
| coil | bd_haus / sn_zome / cymbal_pedal | `:tb303` | house offbeat, 7th chords |
| wire | bd_klub / sn_dub / hat_zan + toms | ring-mod `:pulse` arp | chopped breakbeat, dub skank |
| final | bd_sone / sn_dub / hat_tap | reverb `:pulse` arp | the only track that breathes |

The interludes were also five variations on one drone; each now has a
different drum kit (`bd_zum`, `bd_boom`, `bd_fat`, `bd_klub`, `bd_tek`).

**Tempo changes mid-track.** New in set 7. Every loop calls `use_bpm bpm_for(t)`
as its first act each iteration, so all synced loops shift together — see below.

**Chord movement.** Every track changes key at least once instead of cycling one
four-chord loop start to finish. `final` ends on A major, the set's only major
resolution.

## Architecture note — mid-track tempo changes

Set 6's rule still holds: every `live_loop` body sleeps exactly 32 beats, and
the conductor is a silent metronome (16-beat lead-in, then 32).

Set 7 adds `bpm_for(t)`. Every loop calls `use_bpm bpm_for(t)` immediately after
`tick`, so all loops compute the same tempo for the same section and stay
aligned; `sync: :conductor` re-aligns them each iteration anyway. The conductor
runs one iteration ahead of the music loops, so it uses `bpm_for(t - 1)`.

```ruby
live_loop :conductor do
  t = tick
  stop if t > SONG_END
  use_bpm bpm_for(t.zero? ? 0 : t - 1)   # one ahead of the music loops
  sleep t.zero? ? 16 : 32
end

live_loop :drums, sync: :conductor do
  t = tick
  stop if t >= SONG_END
  use_bpm bpm_for(t)                     # first thing after tick
  # ... always exactly 32 beats
end
```

## Verifying timing

All eight rebuilt tracks were simulated loop-by-loop; every body sums to exactly
32 beats for every value of `t`.

## Running

```bash
./play_set.sh
```

or a single track:

```ruby
run_file "/Users/logan/Projects/chiptune/set7/1. fault.rb"
```
