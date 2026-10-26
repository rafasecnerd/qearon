# Registro de Mudanças / Changelog

Todas as alterações notáveis deste projeto serão documentadas neste arquivo.  
O formato baseia-se em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/), e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
Versão do Software / Software Version: **v0.1.0**

---

## [0.1.0] - 2026-10-26

### [PT-BR] Português

#### Adicionado
- **Arquitetura Modular Monorepo em Zig Puro (0.13.0+)**: Implementação estática sem bibliotecas dinâmicas de terceiros (sem libasound ou libpulse).
- **Descoberta Dinâmica Universal de Hardware (`pipewire.zig` & `alsa.zig`)**: Eliminação de identificadores PCI estáticos ou índices de rota fixos. Descoberta dinâmica de sinks, sources, nós HDMI e perfis de placa via WirePlumber e `/proc/asound/cards`.
- **Motor Multi-Camada de Jack Sensing (`detector.zig`)**: Detecção nativa em 3 camadas: controles de evento ALSA kernel (`amixer cget name='* Jack'`), parsing de registradores de pinos em `/proc/asound/card*/codec#*` (Pin-ctls) e topologia PipeWire (`pw-dump`).
- **Reparo Automatizado de Áudio (`autofix.zig`)**: Rotina sequencial em 6 etapas para desmutar saídas principais, normalizar ganhos, calibrar pré-amplificação de captura para 80% (+20dB boost) e migrar fluxos ativos de mídia (`streams.zig`).
- **Medidor RMS Matemático Real (`vumeter.zig`)**: Amostragem contínua PCM S16LE com cálculo exato do valor eficaz RMS ($\sqrt{\frac{1}{N}\sum x_i^2}$) em 64 bits (anti-overflow), barra ANSI simétrica dual-wing e indicador de pico.
- **Monitoramento de Voz de Baixa Latência (`loopback.zig`)**: Sidetone nativo com latência inferior a 1 ms via `pw-loopback`, isolamento de PID em diretório seguro do usuário (`XDG_RUNTIME_DIR`) e finalização pontual via `kill -15`.
- **Cancelamento Ativo de Ruído (`denoise.zig`)**: Ativação nativa de `libpipewire-module-echo-cancel` com rastreamento de ID para destruição determinística (`pw-cli destroy <id>`) e fallback WebRTC.
- **Forçador de Fone Combinado (`headset`)**: Comutação forçada de rotas de impedância combinadas TRRS para conexões analógicas e virtuais.
- **Auditoria e Diagnóstico (`status` e `tester.zig`)**: Varredura completa de nós PipeWire, emissão de tom senoidal de 440 Hz por canal estéreo e autoteste de gravação de microfone.
- **Sentinela em Segundo Plano (`watcher.zig`)**: Monitoramento contínuo de eventos de conexão física com autocorreção silenciosa.
- **Internacionalização Estrita (`i18n.zig`)**: 100% das strings isoladas em dicionário comptime bilíngue (Português e Inglês) com suporte ao padrão XDG Base Directory (`~/.config/qearon/lang`).
- **Contratos de Saída POSIX (`main.zig`)**: Códigos padronizados `0` (Sucesso), `1` (Erro de Argumentos/Uso) e `2` (Falha de Hardware/Roteamento) com liberação garantida do GPA.
- **Documentação e Metadados Completos**: Diagramas C4 mapeados da AST do código (`docs/diagrama_c4_ast.md`), monografia científica acadêmica (`writeup/`), modelos do GitHub e citação formal (`CITATION.cff`).

#### Corrigido
- **Vazamento Analógico de Hardware (Realtek ALC887)**: Silenciamento obrigatório de canais `Rear Mic`, `Front Mic` e `Line` na matriz de reprodução DAC, eliminando ruído elétrico e chiado de linha.
- **Independência de PulseAudio**: Resolução autônoma via ferramentas nativas PipeWire, eliminando falhas de recusa de conexão em sistemas sem `pipewire-pulse`.
- **Eliminação de Comandos Globais Destrutivos**: Abandono de `pkill` em favor de sinalização POSIX controlada por PID isolado.

---

### [EN] English

#### Added
- **Pure Zig (0.13.0+) Modular Monorepo Architecture**: Static native binary with zero external dynamic library dependencies (no libasound or libpulse).
- **Universal Dynamic Hardware Discovery (`pipewire.zig` & `alsa.zig`)**: Complete elimination of hardcoded PCI addresses or static route indices. Dynamic discovery of sinks, sources, HDMI endpoints, and card profiles via WirePlumber and `/proc/asound/cards`.
- **Multi-Tier Jack Sensing Engine (`detector.zig`)**: 3-tier physical detection: ALSA kernel control events (`amixer cget name='* Jack'`), procfs codec pin register parsing (`/proc/asound/card*/codec#*`), and PipeWire fallback (`pw-dump`).
- **Automated Audio Remediation (`autofix.zig`)**: Deterministic 6-stage linear recovery restoring master playback, calibrating input gain to 80% (+20dB boost), eliminating analog bleed, and synchronizing active client streams (`streams.zig`).
- **True Mathematical RMS Audio Engine (`vumeter.zig`)**: Continuous S16LE PCM stream sampling with exact Root Mean Square ($\sqrt{\frac{1}{N}\sum x_i^2}$) calculation across 64-bit accumulators (preventing overflow), dual-wing symmetric ANSI meter, and peak detection.
- **Low-Latency Voice Monitoring (`loopback.zig`)**: Sub-millisecond hardware sidetone using native `pw-loopback`, process PID isolation in user secure runtime directory (`XDG_RUNTIME_DIR`), and targeted POSIX `kill -15` termination.
- **Active Noise & Echo Cancellation (`denoise.zig`)**: Native PipeWire `libpipewire-module-echo-cancel` loading with tracked module ID for clean destruction (`pw-cli destroy <id>`) and WebRTC fallback.
- **Headset Combiner Switch (`headset`)**: Forced impedance routing for combo TRRS jacks across physical and virtual endpoints.
- **Diagnostics and Verification (`status` and `tester.zig`)**: Comprehensive PipeWire multimedia node inspection, 440 Hz sinusoidal stereo phase test, and self-recording routines.
- **Background Hardware Sentinel (`watcher.zig`)**: Continuous polling daemon with silent auto-remediation on jack plug/unplug events.
- **Strict Centralized Internationalization (`i18n.zig`)**: 100% of operator strings isolated in comptime dictionaries (Portuguese and English) with XDG Base Directory specification compliance (`~/.config/qearon/lang`).
- **Standard POSIX Exit Codes (`main.zig`)**: Return codes `0` (Success), `1` (Argument/Syntax Error), and `2` (Hardware/Routing Failure) with guaranteed GPA memory audits.
- **Comprehensive Documentation Suite**: C4 diagrams generated from codebase AST (`docs/diagrama_c4_ast.md`), academic scientific writeup (`writeup/`), GitHub templates, and citation metadata (`CITATION.cff`).

#### Fixed
- **Analog Hardware Bleed (Realtek ALC887)**: Mandatory muting of `Rear Mic`, `Front Mic`, and `Line` across DAC playback channels, eliminating static electrical hiss and ground loops.
- **PulseAudio Independence**: Full native PipeWire toolchain fallbacks, eliminating connection refused errors on pure PipeWire installations.
- **Destructive Process Cleanups Abolished**: Replaced blunt global `pkill` calls with PID-targeted POSIX `kill -15` signals.

---

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
