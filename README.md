# AudioFrame

A lightweight **Quickshell audio visualizer** that displays a symmetrical, mirrored waveform at the top or bottom of your screen.

AudioFrame uses **CAVA** for real-time audio data and provides a single `Config.qml` file for tuning the visualizer.

---

## Features

- Real-time audio visualization using CAVA
- Symmetrical / mirrored waveform
- Bass-focused center
- Treble/high-frequency response toward the edges
- Top or bottom positioning
- Automatic positioning around existing panels
- Left / center / right alignment
- Configurable waveform width and height
- Configurable peak height
- Configurable audio sensitivity
- Configurable bass / mid / treble response
- Configurable smoothing and decay
- Configurable ridge sharpness
- Configurable beat/transient response
- Transparent background
- Click-through window
- Can run automatically on login using systemd
- Optional Matugen integration can be added for dynamic wallpaper colors

---

# Requirements

You need:

- Linux
- Quickshell
- CAVA
- A working audio system

Check Quickshell:

```bash
quickshell --version
