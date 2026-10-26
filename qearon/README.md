# Repositório de Código-Fonte / Source Code Repository

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software / Software Version: **v0.1.0**

---

## [PT-BR] Português

Este diretório contém a base de código compilável do **Qearon**, implementada em Zig puro (0.13.0+) sem dependências externas de terceiros.

### Estrutura de Arquivos
- `build.zig`: Script oficial de compilação do ecossistema Zig.
- `build.zig.zon`: Manifesto descritivo de pacote do projeto (v0.1.0).
- [`src/`](src/): Módulos organizados por domínio funcional de áudio:
  - `main.zig`: Ponto de entrada CLI, parser e despacho com códigos POSIX.
  - `autofix.zig`: Orquestrador de reparo dinâmico em 6 etapas lineares.
  - `detector.zig`: Jack Sensing multi-tier (ALSA cget, procfs codec e pw-dump).
  - `alsa.zig`: Descoberta dinâmica de placa primária e controle de mixer sem bleed.
  - `pipewire.zig`: Resolução dinâmica de sinks, sources e índices de rotas.
  - `streams.zig`: Migração transparente de fluxos ativos de mídia.
  - `tester.zig`: Teste de fase senoidal 440 Hz e gravação em diretório seguro.
  - `vumeter.zig`: Medidor de nível sonoro com cálculo matemático RMS e barra simétrica.
  - `loopback.zig`: Monitoramento de voz em tempo real com PID isolado em `XDG_RUNTIME_DIR`.
  - `denoise.zig`: Cancelamento de ruído e eco acústico nativo PipeWire.
  - `watcher.zig`: Sentinela contínuo de hardware com autofix silencioso.
  - `installer.zig`: Instalador em `/usr/local/bin` com symlink `mic-fix`.
  - `sys.zig`: Executor de subprocessos com buffer de 4MB e finalizador de PIDs.
  - `i18n.zig`: Central de internacionalização estrita (PT-BR e EN) com padrão XDG.
  - `ui.zig`: Renderização de menus, logos ANSI simétricas e caixas de status.

### Compilação Rápida
```bash
zig build -Doptimize=ReleaseSafe
```
O binário final compilado será gerado em `zig-out/bin/qearon`.

---

## [EN] English

This directory contains the compilable codebase of **Qearon**, implemented in pure Zig (0.13.0+) with zero third-party external dependencies.

### File Structure
- `build.zig`: Official build script for the Zig 0.13.0+ ecosystem.
- `build.zig.zon`: Package description manifest (v0.1.0).
- [`src/`](src/): Functional audio modules:
  - `main.zig`: CLI entry point, argument parser, and POSIX exit code dispatcher.
  - `autofix.zig`: Dynamic 6-stage linear repair coordinator.
  - `detector.zig`: Multi-tier Jack Sensing scanner (ALSA cget, procfs codec, pw-dump).
  - `alsa.zig`: Dynamic primary card discovery, gain calibration, and bleed suppression.
  - `pipewire.zig`: Dynamic resolution of sinks, sources, and route indices.
  - `streams.zig`: Live media stream migration router.
  - `tester.zig`: 440 Hz sinusoidal phase tester and secure directory mic recorder.
  - `vumeter.zig`: Real-time stereo true mathematical RMS VU-meter with symmetric bar.
  - `loopback.zig`: Sub-millisecond voice monitoring with isolated PID management.
  - `denoise.zig`: Active noise suppression and native PipeWire echo cancellation.
  - `watcher.zig`: Continuous hardware sentinel with silent auto-remediation.
  - `installer.zig`: System PATH installer creating `/usr/local/bin/mic-fix` alias.
  - `sys.zig`: Safe subprocess executor with 4MB memory buffers and PID killer.
  - `i18n.zig`: Strict centralized internationalization (PT-BR and EN) with XDG directory support.
  - `ui.zig`: Terminal ANSI banner, menus, and status box rendering.

### Fast Build
```bash
zig build -Doptimize=ReleaseSafe
```
The resulting compiled binary will be placed at `zig-out/bin/qearon`.

---

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
