# Operational and User Manual - Qearon (EN)

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Software Version: **v0.1.0**

---

## 1. Operational Overview

**Qearon** runs directly via command-line interface (`qearon <command> [option]` or through the canonical alias `mic-fix <command> [option]`). Every command executes with deterministic sub-millisecond response, compliant with standard POSIX exit codes (0 for success, 1 for syntax/usage errors, 2 for hardware/subsystem faults).

---

## 2. Complete Command Reference

### 2.1 Repair and Troubleshooting

- `qearon autofix`  
  Executes the full 6-step dynamic recovery pipeline: multi-tier Jack Sensing, dynamic ALSA gain normalization, bleed muting, dynamic PipeWire route resolution, client stream migration, and acoustic stereo validation.
- `qearon headset`  
  Enforces dynamic analog stereo playback and microphone capture profile, redirecting routing to 3.5mm TRRS jacks without assuming hardcoded PCI bus strings.
- `qearon hdmi`  
  Dynamically identifies graphics card HDMI audio endpoints and redirects default playback stream to digital outputs.

### 2.2 Microphone and Voice Tools

- `qearon vu`  
  Launches real-time terminal visualizer powered by **mathematical RMS calculation** ($\sqrt{\frac{1}{N}\sum x_i^2}$) on S16LE PCM frames. Displays a dual-wing symmetric meter (`<[ ||||.... ▲ ....|||| ]>`) with ANSI color gradients, numerical peak percentage, and status indicators (SILENCE, LOW, OPTIMAL, CLIPPING). Exit with `Ctrl+C`.
- `qearon loopback on`  
  Enables sub-millisecond hardware voice monitor (Sidetone) via `pw-loopback`. The active process PID is isolated in `/tmp/qearon_loopback.pid`.
- `qearon loopback off`  
  Safely terminates the isolated voice monitor using POSIX `kill -15` without terminating unrelated loopbacks on the machine.
- `qearon denoise on`  
  Enables active echo cancellation and background noise suppression (`libpipewire-module-echo-cancel`), tracking the native PipeWire module ID.
- `qearon denoise off`  
  Natively destroys the PipeWire filter module (`pw-cli destroy <id>`) and restores direct hardware capture.

### 2.3 Diagnostics and Testing

- `qearon test-sound`  
  Emits clean 440 Hz sinusoidal tones sequentially through Left and Right channels for orientation and phase testing.
- `qearon test-mic`  
  Captures a 2-second microphone audio sample to secure storage (`XDG_RUNTIME_DIR` or `/tmp`) and immediately plays it back in headphones for self-calibration.
- `qearon status`  
  Renders detailed status table including physical connector states (Line Out, Rear Mic, Headphone, Front Mic), ALSA hardware mixers, and PipeWire audio node topologies without duplicate sections.

### 2.4 System Configuration

- `qearon watch`  
  Runs continuous hardware polling sentinel. Detects plug/unplug events on 3.5mm jacks via Jack Sensing and triggers **silent** auto-remediation (no intrusive 440 Hz bursts).
- `qearon install`  
  Compiles production-optimized binary (`ReleaseFast`), installs to `/usr/local/bin/qearon`, and creates the `/usr/local/bin/mic-fix` alias.
- `qearon lang pt` | `qearon lang en`  
  Switches active interface language and saves preference following XDG specification in `~/.config/qearon/lang` (fallback `/tmp/.qearon_prefer`).
- `qearon help`  
  Renders command reference and quick examples.

---

## 3. Process Exit Codes (POSIX Standard)

| Exit Code | Classification | Description |
| :---: | :--- | :--- |
| `0` | **Success** | Operation completed normally. |
| `1` | **Syntax Error** | Unknown command or invalid command arguments. |
| `2` | **Hardware/Driver Error** | ALSA codec inaccessible or PipeWire daemon failure. |

---

## 4. Practical Usage Examples

```bash
# 1. Recover sound and microphone after system boot or suspend:
qearon autofix

# 2. Inspect true RMS microphone modulation in terminal:
qearon vu

# 3. Calibrate voice sensitivity with isolated PID sidetone:
qearon loopback on
# (adjust microphone position and speak)
qearon loopback off

# 4. Enable native PipeWire acoustic echo cancellation:
qearon denoise on

# 5. Launch hardware sentinel with silent remediation:
qearon watch
```

---

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
