# Resilience, Graceful Degradation, and Error Handling

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Software Version: **v0.1.0**

---

## 1. Resilience Philosophy

> *"Programmers are not those who write perfect code, but those who know how to fix errors."*  
> — **[Barbara Liskov](https://en.wikipedia.org/wiki/Barbara_Liskov)** (Turing Award winner and Computer Science pioneer)

Qearon operates under the core principles of **graceful degradation** and **non-destructive operation**. Failures in peripheral subsystems (such as the absence of a PulseAudio emulation server or persistence daemon) must never interrupt the core ALSA hardware remediation or monitoring pipeline.

```
+-------------------------------------------------------------+
|                      Requested Command                      |
+-------------------------------------------------------------+
                              |
              +---------------+---------------+
              |                               |
       [Direct Success]              [Subsystem Failure]
              |                               |
       [Success Return]              [Fallback Triggered]
                                              |
                                   +----------+----------+
                                   |                     |
                            [Soft Degradation]   [Non-Fatal Warning]
```

---

## 2. Recovery Strategies per Subsystem

### 2.1 ALSA Subsystem (`src/alsa.zig`)
* **Dynamic Card Discovery**: Rather than fixing index `0`, Qearon dynamically inspects `/proc/asound/cards` to isolate the primary analog audio card, disregarding non-analog or HDMI endpoints when adjusting mic capture.
* **Tolerant Mixer Control Discovery**: Controls vary across motherboard vendors (e.g., absence of `Front` or `Headphone` channels). Minor control errors are ignored gracefully without breaking `Master` or `Capture` adjustments.
* **Guarantee**: Microphone capture and primary master output are always restored with proper gain.

### 2.2 PipeWire Routing Subsystem (`src/pipewire.zig`)
* **Elimination of Static Paths**: Sinks, sources, and hardware route indices are dynamically resolved at runtime via `pw-dump` JSON parsing, making Qearon universal across all architectures and distributions.
* **PulseAudio Independence**: Operations gracefully degrade directly to native PipeWire tools (`pw-cli`, `wpctl`, `pw-loopback`, `pw-dump`).
* **Guarantee**: The application never crashes due to `Connection refused` errors on legacy PulseAudio sockets.

### 2.3 Real-Time Loopback Subsystem (`src/loopback.zig`)
* **PID Isolation**: The PID of the detached `pw-loopback` process is tracked in the secure user runtime directory (`XDG_RUNTIME_DIR/qearon_loopback.pid`, with fallback to `/tmp`).
* **Safe POSIX Signaling**: Running `qearon loopback off` issues a controlled `kill -15` strictly to the recorded PID, completely eliminating harmful global `pkill` calls.

### 2.4 Active Noise Suppression Subsystem (`src/denoise.zig`)
* **Native Module ID Tracking**: Active PipeWire echo cancellation module IDs are recorded in the secure user runtime directory (`XDG_RUNTIME_DIR/qearon_denoise.pw_id`, with fallback to `/tmp`).
* **Deterministic Removal**: Teardown issues `pw-cli destroy <id>` directly into PipeWire's native IPC, alongside seamless fallback to PulseAudio module unloader.

---

## 3. System Exit Codes (POSIX)

| Code | Identifier | Technical Meaning |
| :---: | :--- | :--- |
| `0` | `SUCCESS` | Execution completed without errors or with handled degradations |
| `1` | `ARGUMENT_ERROR` | Invalid or unsupported command-line arguments |
| `2` | `HARDWARE_UNAVAILABLE` | No physical sound card detected in the ALSA subsystem or critical fault |

---

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
