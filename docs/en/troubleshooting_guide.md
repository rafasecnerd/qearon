# Troubleshooting and Diagnostics Guide

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Software Version: **v0.1.0**

---

## 1. Problem Classification Matrix

The diagnostic engine maps failures into four operational vectors:

| Component | Failure Symptom | Probable Cause | Action |
| :--- | :--- | :--- | :--- |
| **Physical Layer (Jack)** | Microphone or headphone not listed | Unplugged jack or damaged connector | Audit ALSA jack controls via `amixer -c <card> cget iface=CARD,name='* Jack'` |
| **Kernel / ALSA** | Total audio silence or electrical hiss | Channel muted or analog feedback active | Execute `qearon autofix` to reset registers on primary card |
| **Routing / PipeWire** | Audio in wrong output device | Fallback/default sink set incorrectly or orphaned node | Audit via `qearon status` and rerun `qearon autofix` |
| **Loopback / Latency** | High latency or zombie process | Inactive previous monitor session | Stop cleanly with isolated PID via `qearon loopback off` |

---

## 2. Common Issues and Resolutions

### Issue 1: High-Pitched Hiss / Analog Feedback
* **Context**: Realtek ALC887/ALC892/ALC1220 / HDA Intel codecs with open playback sliders in the mixer.
* **Mechanism**: Hardware mixing copies the 3.5mm input directly to output DACs prior to software processing.
* **Solution**:
  ```bash
  qearon autofix
  ```
  > [!NOTE]
  > This command explicitly mutes `Rear Mic`, `Front Mic`, and `Line` under ALSA playback while preserving the `Capture` channel active within the ADC converter.

### Issue 2: Microphone Level Too Low
* **Context**: Inactive hardware preamp or attenuated capture gain.
* **Mechanism**: Dynamic microphones or 3.5mm headsets require gain amplification (bias voltage and input gain).
* **Solution**:
  1. Inspect capture level in real time with the true RMS dynamic meter:
     ```bash
     qearon vu
     ```
  2. If modulation remains below 10%, recalibrate boost channels automatically via `qearon autofix` or manually by discovering the primary analog card:
     ```bash
     # Find analog primary card index:
     cat /proc/asound/cards
     
     # Calibrate gain and preamplifier:
     amixer -c <card> set 'Capture' 80%
     amixer -c <card> set 'Mic Boost' 2
     ```
  > [!TIP]
  > A boost level of 2 (+20dB) is recommended. Step 3 (+30dB) often introduces harmonic distortion and unwanted electrical noise.

### Issue 3: PipeWire Service Communication Error
* **Context**: Inactive audio daemon or unreachable communication socket.
* **Mechanism**: Qearon commands fail during node graph topology retrieval.
* **Solution**:
  1. Verify user service status:
     ```bash
     systemctl --user status pipewire.service
     ```
  2. Restart services if necessary:
     ```bash
     systemctl --user restart pipewire wireplumber
     ```
  > [!IMPORTANT]
  > Qearon operates autonomously and does not require `pipewire-pulse` for hardware remediation and low-latency loopback.

---

## 3. Advanced Diagnostic Routine

When automated recovery fails, execute the stepwise manual triage:

1. **Dump Primary Card and Codec State**:
   ```bash
   cat /proc/asound/cards
   cat /proc/asound/card*/codec#* | grep -E "Codec|Pin Complex" | head -n 30
   ```
2. **Inspect Mixer Volumes**:
   ```bash
   amixer -c 0 scontents
   ```
3. **Inspect Real-Time Node Graph**:
   ```bash
   pw-top
   ```

---

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
