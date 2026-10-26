# Roteiro de Evolução / Project Roadmap

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software / Software Version: **v0.1.0**

---

## [PT-BR] Português

O objetivo de longo prazo do **Qearon** é evoluir de uma ferramenta de linha de comando para uma suíte completa de processamento, diagnóstico e inteligência de áudio em tempo real para Linux.

### Entregue na Versão Atual (v0.1.0)
- **Descoberta Dinâmica Universal**: Eliminação total de strings PCI ou índices fixos de placas ALSA; resolução de nós via `pw-dump` e `/proc/asound/cards`.
- **Jack Sensing Multi-Tier**: Auditoria em 3 camadas: controles de evento ALSA kernel, procfs codec pin-ctls e topologia PipeWire.
- **Medidor RMS Matemático**: Cálculo de valor eficaz ($\sqrt{\frac{1}{N}\sum x_i^2}$) em quadros S16LE com barra ANSI simétrica e indicador de pico.
- **Isolamento de PIDs e Segurança de Processos**: Arquivos de controle em `XDG_RUNTIME_DIR` (com fallback em `/tmp`), terminação segura `kill -15` (abolição de `pkill`), e destruição de nós nativos via `pw-cli destroy`.
- **Conformidade POSIX**: Códigos de saída estritos (0=Sucesso, 1=Sintaxe, 2=Hardware).

### Fase 1: Interfaces Gráficas e Usabilidade (Próximas Versões)
- **Painel Desktop Nativo**: Interface gráfica leve construída sem dependências pesadas de Chromium/Electron, utilizando bindings diretos para Wayland/X11 ou toolkit nativo de alta eficiência.
- **WebGUI Local**: Painel web leve servido localmente em porta configurável para gerenciamento de áudio via navegador ou dispositivos móveis na mesma rede local.
- **Applet de Bandeja (System Tray)**: Indicador de status de microfone, botão de mute rápido e controle de supressão de ruído no painel do sistema.

### Fase 2: Utilitários Avançados de Áudio (v0.3.0 - v0.4.0)
- **Gravador de Áudio Sem Perdas**: Módulo integrado para gravação de fluxos com exportação direta para FLAC, WAV e Opus com marcação de tempo precisa.
- **Transcrição de Voz para Texto (Voice-to-Text)**: Integração com modelos locais de inferência compacta (Whisper C/Zig) para transcrição de microfone em tempo real sem envio de dados para servidores externos.
- **Equalizador Paramétrico de 10 Bandas**: Filtros biquad em tempo real acoplados diretamente ao grafo de nós do PipeWire.

### Fase 3: Processamento por Inteligência Artificial (v0.5.0+)
- **Modificador de Voz com IA Local (VoiceMod AI)**: Transformação de timbre e voz em tempo real através de modelos neurais quantizados rodando localmente na GPU/NPU.
- **Supressão de Ruído Neural (RNNoise / DeepFilterNet)**: Filtro acústico profundo com latência inferior a 10ms treinado para cancelamento de cliques de teclado mecânico e ruídos de ventilador.
- **Auto-Equalização de Sala**: Emissão de pulsos de teste acústico e calibração automática da curva de resposta de fones e microfones.

---

## [EN] English

The long-term mission of **Qearon** is to evolve from an autonomous CLI repair utility into a comprehensive audio diagnostics, orchestration, and real-time artificial intelligence suite for Linux.

### Delivered in Current Version (v0.1.0)
- **Universal Dynamic Discovery**: Full elimination of hardcoded PCI identifiers or static ALSA card indices; runtime resolution via `pw-dump` and `/proc/asound/cards`.
- **Multi-Tier Jack Sensing**: 3-tier auditing: kernel ALSA event controls, procfs codec pin-ctls, and PipeWire topology.
- **Mathematical RMS Meter**: True Root Mean Square ($\sqrt{\frac{1}{N}\sum x_i^2}$) calculation on S16LE frames with symmetric ANSI visualizer and peak percentage.
- **PID Isolation and Process Safety**: Process control tracking via `XDG_RUNTIME_DIR` (with `/tmp` fallback), safe POSIX `kill -15` (abolition of global `pkill`), and native PipeWire module destruction via `pw-cli destroy`.
- **POSIX Exit Code Conformance**: Canonical return codes (0=Success, 1=Syntax/Usage, 2=Hardware).

### Phase 1: Graphical Interfaces & Accessibility (Planned Features)
- **Native Desktop Dashboard**: Lightweight graphical frontend built without heavy Chromium/Electron runtimes, utilizing direct high-efficiency Wayland/X11 bindings.
- **Local WebGUI**: Zero-overhead local HTTP dashboard for browser-based audio management across local network devices.
- **System Tray Applet**: Real-time microphone status indicator, fast mute toggle, and noise filter selector.

### Phase 2: Advanced Audio Utilities (v0.3.0 - v0.4.0)
- **Lossless Audio Recorder**: Integrated lossless capture engine supporting FLAC, WAV, and Opus with sub-millisecond timestamp precision.
- **Voice-to-Text Transcription**: Local Whisper C/Zig inference engine for real-time speech transcription with zero cloud dependency.
- **10-Band Parametric Equalizer**: Real-time biquad filtering nodes plugged directly into the PipeWire processing graph.

### Phase 3: Artificial Intelligence Audio Processing (v0.5.0+)
- **Local AI Voice Changer (VoiceMod AI)**: Real-time voice timbre transformation powered by quantized neural models executed locally on GPU/NPU.
- **Deep Neural Noise Suppression (RNNoise / DeepFilterNet)**: Deep acoustic filtering under 10ms latency targeting mechanical keyboard strikes and fan noise.
- **Automated Room Response Calibration**: Impulse testing routines calculating inverse filters for connected headphones and microphones.

---

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
