# Chiptune Project

Sonic Pi music inspired by GO! with fourteen o. Workflow: yt-dlp → librosa analysis → Sonic Pi `.rb` files.

## Files

- `gun_fingers.rb` — 162 BPM, G minor (Gm–Eb–Dm–Cm), verse/chorus structure with full melody
- `four_more_years.rb` — 148 BPM, Eb minor (Ebm–B–Bbm–Gb), minimal — melody appears once (first chorus only)
- `samples/` — downloaded reference audio

## Running

Sonic Pi's GUI buffer overflows on these files. Always run with:
```ruby
run_file "/Users/logan/Projects/chiptune/<filename>.rb"
```

## Sonic Pi timing rules (critical)

Every `live_loop` body must sleep an **exact multiple of 4 beats**. Both files use 32-beat loops. Verify with:
```ruby
ruby -e "
  content = File.read('file.rb')
  content.scan(/define :(\w+) do.*?^end/m) { |m|
    total = $~[0].scan(/sleep ([\d.]+)/).sum { |s| s[0].to_f }
    puts \"#{m[0]}: #{total}\"
  }
"
```

## Architecture pattern

All files use the same sync architecture:

```ruby
live_loop :conductor do       # fires every 32 beats
  t = tick
  stop if t > SONG_END        # conductor plays one extra iteration (the intro)
  # ... play music or sleep 32
end

live_loop :drums, sync: :conductor do   # re-aligns every iteration
  t = tick
  stop if t >= SONG_END       # non-conductors stop one iteration earlier
  sec = (t / 2) % 4
  # ...
end
```

**Why `sync:` parameter not `sync` in body:** `sync:` resolves before the first iteration — eliminates the startup race condition that causes drum dropouts.

**16-beat intro trick:** The conductor plays `sleep 16` (or a 16-beat melody) on `t==0`. Other loops miss this first fire (still starting up) and arrive at `t==1`. Conductor uses `sec = ((t-1)/2) % 4` for `t >= 1`; drums use `(tick/2) % 4` — both track the same section.

**Section mapping** (`(tick/2) % 4`):
- 0 → verse / first section
- 1 → chorus / second section
- 2 → verse 2 / third section
- 3 → chorus / fourth section

Chorus detection: `[1, 3].include?(sec)`

## Melody philosophy

- Melody supports vocals — stays out of the way (sparse, quarter notes, mid-low register)
- `gun_fingers`: full verse+chorus melody throughout
- `four_more_years`: melody only in first chorus — rest is bass/drums/arp
- D→Eb→D sting motif in G minor pieces; E→Eb crush in Eb minor pieces

## Synths and samples

| Role | Synth | Key params |
|------|-------|-----------|
| Chip lead (gun_fingers) | `:pulse` | `pulse_width: 0.12, cutoff: 82` |
| Chip lead (four_more_years) | `:pulse` | `pulse_width: 0.45, cutoff: 78` — wider = colder |
| Bass | `:chipbass` | `sustain: 0.2, release: 0.08` |
| Arp | `:pulse` + `:bitcrusher` | `bits: 6-7, sample_rate: 0.4-0.5` |

Drums: `:bd_haus` (gun_fingers) vs `:bd_fat` (four_more_years); `:sn_dolf` vs `:sn_dub`; `:hat_snap` vs `:hat_metal`

## Analysis pipeline

```bash
yt-dlp -x --audio-format mp3 -o "samples/%(title)s.%(ext)s" <URL>
python3 analyze.py  # librosa: BPM (often half-time, double it), key, chroma, spectral centroid
```

BPM detector often returns half-time for hyperpop — double the result if it seems slow.

## User preferences

- No screaming/vocals in analysis or code — instrumental only
- Melody should not compete with a vocalist on top
- Songs should have a defined end (`SONG_END` constant at top of file)
- Simpler is better — don't add complexity without being asked
