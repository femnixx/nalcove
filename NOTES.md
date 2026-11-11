# Phase 13 Notes — Mixer Redesign

## 13.0 Observations

### Current ControlsTab.qml layout
- Output section: Text label + DeviceSelector (sink dropdown) + mute icon + FlatSlider + pct text — all in one Row
- Input section: same pattern with sources
- Divider line
- AppMixer component (per-app rows with volume slider, output dropdown, pct)

### Current AppMixer.qml
- Repeater over `Services.Audio.appStreams`
- Each row: app icon (28px), name/detail labels, FlatSlider, output selector dropdown (120px wide), pct text
- Output selector dropdown uses `DeviceSelector`-like inline list
- **Bug**: "Applications" label overlaps Output row (both in same column without proper spacing)

### Required icons (all MISSING from both Icon.qml glyphMap and icons/ directory)
- `volume-2` — speaker icon for unmuted Output
- `volume-x` — speaker icon for muted Output  
- `mic` — microphone icon for unmuted Input
- `mic-off` — microphone icon for muted Input
- `ellipsis-vertical` — kebab menu button
- `headphones` — per-app output selector
- `app-window` — neutral app icon fallback

**ACTION NEEDED**: Clone Lucide SVGs into `island/icons/` as in Phase 3, then add glyphs to `Icon.qml` glyphMap.

### pactl sink-inputs mapping (13.0)
```
pactl --format=json list sink-inputs
```
Single sink-input found while Waterfox is playing:
- `index`: 1028 (pactl index for `move-sink-input`)
- `properties.object.id`: "144" (PipeWire object id)
- `properties.application.name`: "Waterfox"
- `properties.media.name`: "Corny Posts Getting Cooked By Instagram Comments🥀💔 (Best Of) - YouTube"
- `properties.application.icon-name`: null/missing
- `properties.application.id`: null/missing
- `properties.application.process.binary`: "waterfox-bin"

### PwNode.id vs object.id mapping (13.0)
Could not confirm whether Quickshell's `PwNode.id` equals pactl `object.id` (144) or pactl `index` (1028). Current `moveStreamToSink` uses `String(n.id)` for `pactl move-sink-input <id> <sink>`, which would need the pactl index (1028), not object.id (144).

**Step 13.5 status**: SKIPPED — cannot confirm stable id mapping, hiding headphones button until mapping is proven.

### App icon checkerboard cause (13.0)
`Quickshell.iconPath(name, fallback)` is called with `appIconName()` which returns `application.icon-name` — this is null/missing for Waterfox, so it falls back to `"audio-x-generic"` which doesn't exist as an SVG, producing the magenta/black checkerboard placeholder from `image://icon/...`.

### verify.sh
Not found in project root.
