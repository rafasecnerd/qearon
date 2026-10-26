# Software Architecture - Qearon (EN)

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Software Version: **v0.1.0**

---

## 1. Overview and Architectural Principles

**Qearon** is engineered as a linear modular monorepo written in **pure Zig**, designed for sub-millisecond startup, memory consumption below 2 MB, and complete independence from heavy third-party runtime libraries.

### Core Principles:
1. **Language Purism**: Written entirely in Zig, delivering deterministic static compilation, explicit memory allocation management (`std.mem.Allocator`), and compile-time type safety with zero garbage collection pauses.
2. **Linear Simplicity**: Clean layout under `src/`, free from complex metaprogramming, implicit inheritance, or obscure macro preprocessors.
3. **Separation of Concerns**: Presentation formatting (`src/ui.zig`) is decoupled from user-facing text dictionaries (`src/i18n.zig`) and platform driver abstractions (`src/alsa.zig`, `src/pipewire.zig`).
4. **Universal Dynamic Topology**: Zero hardcoded PCI identifiers, fixed ALSA card indices, or static routes. Hardware topology is dynamically discovered via `/proc/asound/cards` and PipeWire graph inspection (`pw-dump`).
5. **Process Isolation & Safety**: Background tasks (e.g., `pw-loopback`) are isolated via dedicated PID tracking files (`/tmp/qearon_loopback.pid`) and managed using graceful POSIX `kill -15` signaling, abolishing blunt system-wide `pkill` calls.
6. **Resilience and Graceful Degradation**: Non-critical step failures yield clear warnings without interrupting core audio stream recovery, adhering to strict POSIX exit codes (0=Success, 1=Syntax/Usage, 2=Hardware).

---

## 2. AST Module Map (`qearon/src/`)

```text
qearon/src/
├── main.zig         # Program entry point, argument parsing, and command dispatcher with POSIX exit codes
├── ui.zig           # ANSI visual engine, Unicode borders, and spectrum wave renderer
├── i18n.zig         # Compile-time internationalization dictionary (PT/EN) with XDG directory support
├── autofix.zig      # Linear 6-step dynamic audio repair state machine
├── detector.zig     # Multi-tier Jack Sensing: ALSA cget, procfs codec pin-ctls, and pw-dump fallback
├── alsa.zig         # Dynamic primary card discovery, analog gain calibration, and bleed suppression
├── pipewire.zig     # Dynamic locale-agnostic audio sink/source and route index resolver
├── streams.zig      # Zero-drop live client stream migration engine
├── tester.zig       # Stereo phase tester and acoustic voice recorder with safe runtime directory
├── vumeter.zig      # Real-time PCM stream sampler with true mathematical RMS and symmetric meter
├── loopback.zig     # Sub-millisecond hardware sidetone manager with isolated PID management
├── denoise.zig      # Real-time acoustic echo and noise filter manager with native module ID destruction
├── watcher.zig      # Background polling sentinel with silent autofix remediation
├── installer.zig    # System PATH installer for /usr/local/bin/qearon and canonical mic-fix alias
└── sys.zig          # Safe subprocess and pipe executor with 4MB memory buffers and PID killer
```

---

## 3. Repair Execution Pipeline (`autofix`)

The automated recovery workflow executes a deterministic 6-stage linear state machine:

```text
[Start]
   │
   ├─► [1/6] Multi-Tier Jack Sensing: Audits ALSA kernel events via 'cget iface=CARD,name=* Jack',
   │         inspects /proc/asound/card*/codec#* pin complexes, and parses pw-dump topology.
   │         Identifies front, rear, or headset connections dynamically.
   │
   ├─► [2/6] Dynamic ALSA Calibration: Detects non-HDMI primary card in /proc/asound/cards.
   │         Normalizes Master (85%), Front (100%), Headphone (100%).
   │         Mutes analog mic playback bleed (Rear Mic, Front Mic) to eliminate electrical hiss.
   │         Sets Capture gain to 80% and Mic Boost to 2 (+20 dB).
   │
   ├─► [3/6] Dynamic PipeWire Routing: Discovers analog sink and source IDs dynamically
   │         without relying on static PCI device paths. Configures hardware routes accordingly.
   │
   ├─► [4/6] Stream Migration: Enumerates running client inputs (browsers, Discord, players)
   │         and transitions them to the active analog sink without playback drop.
   │
   ├─► [5/6] Persistence: Executes 'alsactl store <card>' using discovered card ID.
   │
   └─► [6/6] Output Validation: Emits 440 Hz sinusoidal signals across Left and Right channels
             (optionally silenced during hotplug auto-remediation by the background watcher).
[End]
```

---

## 4. Low-Level Subsystem Integration

- **ALSA (Advanced Linux Sound Architecture)**: Communicates dynamically with `/dev/snd/controlC*` and `/proc/asound/cards`. Invokes `amixer` for preamplifier gain, mixer impedance, and route muting.
- **PipeWire Graph**: Dynamic routing without legacy PulseAudio dependencies, leveraging `pw-dump` for JSON topology discovery, `wpctl` for node selection, `pw-loopback` for 1 ms hardware voice monitoring, and `pw-cli` for native module lifecycles.

---

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
