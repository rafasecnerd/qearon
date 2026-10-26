# Modelo C4 e Análise de AST / C4 Model and AST Analysis

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software / Software Version: **v0.1.0**

---

## [PT-BR] Português

O modelo C4 (Contexto, Contêineres, Componentes e Código) fornece uma representação hierárquica e formal da arquitetura do Qearon. Esta análise mapeia com precisão matemática a Árvore Sintática Abstrata (AST) do código-fonte compilado em Zig.

### Nível 1: Diagrama de Contexto de Sistema
Descreve as fronteiras do Qearon em relação ao usuário, ao kernel Linux (ALSA) e ao servidor de áudio moderno (PipeWire / WirePlumber).

```mermaid
graph TD
    User["Usuário / Operador"]
    Qearon["Qearon CLI (v0.1.0)<br/>Utilitário Nativo em Zig"]
    AlsaKernel["Kernel Linux / ALSA<br/>Drivers de Hardware snd_hda_intel e procfs"]
    PipeWireServer["PipeWire & WirePlumber<br/>Servidor de Áudio e Roteamento de Grafo Dinâmico"]
    HardwareAudio["Hardware de Áudio (ex: Realtek ALC887 / HDA Intel)<br/>Painel Frontal, Traseiro P2 e HDMI"]

    User -->|"Executa comandos (reparar, vu, retorno, fone)"| Qearon
    Qearon -->|"Manipula mixers dinâmicos e Jack Sensing (/proc/asound, amixer)"| AlsaKernel
    Qearon -->|"Descobre nós via pw-dump e controla rotas/filtros"| PipeWireServer
    AlsaKernel -->|"Comunica via barramento PCI/HDA"| HardwareAudio
    PipeWireServer -->|"Submete streams PCM de baixa latência"| AlsaKernel
```

---

### Nível 2: Diagrama de Contêineres
Mapeia a distribuição do software no sistema operacional, a camada de persistência e os canais IPC.

```mermaid
graph TD
    subgraph "Ambiente do Sistema Operacional Linux"
        BinQearon["/usr/local/bin/qearon<br/>Executável ELF nativo em Zig"]
        AliasMicFix["/usr/local/bin/mic-fix<br/>Symlink canônico para qearon"]
        ConfigLang["~/.config/qearon/lang<br/>Persistência de idioma (XDG)"]
        CachePID["XDG_RUNTIME_DIR/qearon_loopback.pid<br/>Arquivo de rastreio de PID do Loopback"]
        CachePW["XDG_RUNTIME_DIR/qearon_denoise.pw_id<br/>ID de módulo nativo do PipeWire"]
        AlsaMixerBin["amixer & alsactl<br/>Interface de controle de kernel"]
        PipeWireBin["pw-cli, wpctl, pw-dump, pw-loopback<br/>Ferramentas nativas do subsistema PipeWire"]
    end

    BinQearon -->|"Lê e grava preferência de locale"| ConfigLang
    BinQearon -->|"Isola PID para término seguro (kill -15)"| CachePID
    BinQearon -->|"Armazena ID para destruição nativa (pw-cli destroy)"| CachePW
    BinQearon -->|"Executa descoberta e ajustes de hardware"| AlsaMixerBin
    BinQearon -->|"Descobre topologia dinâmica e injeta nós de filtro"| PipeWireBin
    AliasMicFix -->|"Aponta para"| BinQearon
```

---

### Nível 3: Diagrama de Componentes (Mapeamento da AST)
Reflete a estrutura modular sequencial e a hierarquia exata de chamadas de funções entre os módulos de `qearon/src/`.

```mermaid
graph TD
    subgraph "qearon/src/ (AST do Monorepo v0.1.0)"
        Main["main.zig<br/>Despachante CLI e Códigos POSIX"]
        UI["ui.zig<br/>Renderizador ANSI, Banners e Oscilograma"]
        I18N["i18n.zig<br/>Tabelas Estritas de Localização (PT/EN)"]
        Autofix["autofix.zig<br/>Orquestrador de Reparo Dinâmico"]
        Detector["detector.zig<br/>Jack Sensing Multi-Tier (cget + procfs)"]
        AlsaMod["alsa.zig<br/>Detecção de Placa Primária e Mixer"]
        PipeWireMod["pipewire.zig<br/>Seletor Dinâmico de Sinks e Sources"]
        StreamsMod["streams.zig<br/>Migrador de Streams Ativos"]
        TesterMod["tester.zig<br/>Gerador 440Hz e Verificador de Microfone"]
        VuMeter["vumeter.zig<br/>Medição RMS Real e Barra Simétrica"]
        Loopback["loopback.zig<br/>Sidetone com PID Isolado (XDG/tmp)"]
        Denoise["denoise.zig<br/>Cancelamento de Eco Nativo (pw-cli)"]
        Watcher["watcher.zig<br/>Sentinela Contínuo com Autofix Silencioso"]
        Installer["installer.zig<br/>Instalador e Gerenciador de Links"]
        Sys["sys.zig<br/>Executor de Subprocessos com 4MB Buffer"]
    end

    Main -->|"Consulta traduções"| I18N
    Main -->|"Renderiza layouts e logos"| UI
    Main -->|"Dispara diagnóstico"| Autofix
    Main -->|"Inicia monitoramento"| VuMeter
    Main -->|"Gerencia sidetone"| Loopback
    Main -->|"Gerencia filtro"| Denoise
    Main -->|"Inicia sentinela"| Watcher
    Main -->|"Instala binários"| Installer

    Autofix --> Detector
    Autofix --> AlsaMod
    Autofix --> PipeWireMod
    Autofix --> StreamsMod
    Autofix --> TesterMod

    Detector --> Sys
    AlsaMod --> Sys
    PipeWireMod --> Sys
    StreamsMod --> Sys
    TesterMod --> Sys
    Loopback --> Sys
    Denoise --> Sys
    Watcher --> Detector
    Watcher --> Autofix
    VuMeter --> Sys
    Installer --> Sys
```

---

## [EN] English

The C4 model (Context, Containers, Components, and Code) provides an architectural decomposition of Qearon. This breakdown is mathematically derived from the Abstract Syntax Tree (AST) of the Zig codebase.

### Level 1: System Context Diagram
Defines Qearon's boundaries in relation to the operator, Linux kernel (ALSA), and modern audio infrastructure (PipeWire / WirePlumber).

- **User**: Invokes commands such as `autofix`, `vu`, `loopback`, `denoise`, and `headset`.
- **Qearon CLI**: Autonomous Zig binary (v0.1.0) responsible for dynamically auditing and orchestrating audio routes.
- **ALSA Kernel**: Kernel audio drivers controlling hardware mixers, sound cards, and procfs Jack Sensing states.
- **PipeWire / WirePlumber**: High-performance audio graph engine handling dynamic stream routing without static PCI paths.

### Level 2: Container Diagram
Details runtime deployment, IPC interfaces, and storage artifacts.

- **Executable**: Compiled binary installed at `/usr/local/bin/qearon` with `/usr/local/bin/mic-fix` alias.
- **Locale Configuration**: Persistent preference stored at `~/.config/qearon/lang` (XDG standard) with fallback to `/tmp/.qearon_prefer`.
- **Process Isolation State**: Active loopback PID persisted at `XDG_RUNTIME_DIR/qearon_loopback.pid` (with fallback to `/tmp`) for deterministic POSIX `kill -15` management.
- **PipeWire Native Module Tracking**: Loaded echo-cancellation module ID tracked at `XDG_RUNTIME_DIR/qearon_denoise.pw_id` (with fallback to `/tmp`) for deterministic destruction via `pw-cli destroy <id>`.
- **System Tooling**: Subprocess execution targeting `amixer`, `wpctl`, `pw-dump`, and `pw-loopback`.

### Level 3: Component Diagram (AST Decomposition)
Reflects the exact call graph and modular isolation in `qearon/src/`.

- `main.zig`: Application entry point, argument parsing, strict POSIX exit code dispatching (0=Success, 1=Syntax, 2=Hardware).
- `ui.zig`: Pure ANSI presentation engine, box drawing, and spectrum wave visualization.
- `i18n.zig`: Centralized compile-time string dictionary isolating PT-BR and EN, supporting XDG directory resolution.
- `autofix.zig`: Autonomous 6-stage remediation engine coordinating dynamic sound cards, sinks, sources, and routes.
- `detector.zig`: Multi-tier Jack Sensing (ALSA control cget `iface=CARD,name='* Jack'`, procfs codec pin-ctls, pw-dump fallback).
- `alsa.zig`: Dynamic primary card discovery via `/proc/asound/cards`, hardware gain calibration, analog bleed muting, and mixer control.
- `pipewire.zig`: Locale-independent, dynamic sink/source and route index resolver using `pw-dump` (zero hardcoded PCI strings).
- `streams.zig`: Live audio client stream migration without playback interruptions.
- `tester.zig`: Non-blocking 440 Hz acoustic tone emission and self-recording routines using `XDG_RUNTIME_DIR`.
- `vumeter.zig`: Real-time PCM stream sampler with true mathematical RMS ($\sqrt{\frac{1}{N}\sum x_i^2}$) calculation and dual-wing symmetric ANSI visualizer.
- `loopback.zig`: Sub-millisecond hardware sidetone manager with dedicated PID tracking and safe POSIX signaling.
- `denoise.zig`: Real-time acoustic echo cancellation with native PipeWire module tracking and removal.
- `watcher.zig`: Polling event loop detecting hardware plug/unplug events with silent autofix remediation.
- `installer.zig`: System-wide binary installation and symlink management (`qearon` and `mic-fix`).
- `sys.zig`: Memory-safe subprocess execution layer with pipe isolation and 4MB buffer capacity.

---

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
