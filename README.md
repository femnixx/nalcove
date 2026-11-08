# Dynamic Island for Linux Wayland (Quickshell)

A macOS Dynamic Island / notch replacement for Linux Wayland compositors,
inspired by Alcove (macOS) and NotchNook-style notch apps.

## Stack

- Quickshell + QML (Qt 6) using wlr-layer-shell
- No Tauri, React, Electron, Node, or web technology

## Project Structure

```
island/
  shell.qml            # Entry point (ShellRoot)
  Island.qml           # PanelWindow + state machine (closed/hover/hotkey)
  IslandShape.qml      # Custom notch shape via QtQuick.Shapes
  Theme.qml            # Singleton: colors, sizes, spring values
  qmldir               # QML module registration
  components/          # ExpandedContent, PillMedia, PillBattery, Hud
  services/            # Media, Power, Stats service wrappers
scripts/run.sh         # Launch script: qs -p ./island
```

## Running

```bash
cd /home/archlinux/projects/dynamic-notch-niri
./scripts/run.sh
```

Or manually:
```bash
qs -p ./island
```

## Requirements

- Quickshell
- Qt 6 Declarative
- QtQuick.Shapes module

## Hotkey Binds

### Hyprland
Add to `hyprland.conf`:
```
bind = SUPER, N, global, qs ipc call island toggle
```
Or use `GlobalShortcut` (appId: "island", name: "toggle") if your build supports it.

### Other Compositors (sway, niri, river, KDE, GNOME)
Bind any hotkey to:
```
qs ipc call island toggle
```

Or bind to launch/terminate the Quickshell process directly.

## States

- **closed**: Idle notch (200×34), hover-to-peek enabled
- **hover**: Peek expanded (360×80) while pointer is over the island; closes after 150 ms debounce on exit
- **hotkey**: Locked open (640×220), keyboard focus OnDemand, Escape to close

## Notes

- The layer surface is fixed-size and never resized during animation
- Input mask restricts clicks to the island shape only; everything else is click-through
- Nothing runs when closed and idle (no animations, no timers)
