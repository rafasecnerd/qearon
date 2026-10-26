# Arquitetura de Software - Qearon (PT-BR)

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software: **v0.1.0**

---

## 1. Visão Geral e Princípios Arquiteturais

O **Qearon** é construído como um monorepo modular linear em **Zig puro**, projetado para operar com latência mínima, consumo de memória inferior a 2 MB e ausência absoluta de dependências de bibliotecas dinâmicas externas.

### Princípios Fundamentais:
1. **Purismo de Linguagem**: Escrito exclusivamente em Zig, garantindo compilação estática previsível, controle manual de alocação de memória (`std.mem.Allocator`) e segurança em tempo de compilação sem necessidade de coletor de lixo (GC).
2. **Linearidade e Simplicidade**: Estrutura sequencial em `src/`, sem metaprogramação complexa, herança oculta ou macros obscuras.
3. **Isolamento de Responsabilidades**: A camada de visualização (`src/ui.zig`) é desacoplada dos textos (`src/i18n.zig`) e dos drivers de sistema (`src/alsa.zig`, `src/pipewire.zig`).
4. **Universalidade e Descoberta Dinâmica**: Nenhum identificador PCI, placa ALSA ou índice de rota é mantido fixo (hardcoded) no código. O sistema inspeciona dinamicamente `/proc/asound/cards` e o grafo JSON do PipeWire (`pw-dump`).
5. **Isolamento e Segurança de Processos**: Processos em segundo plano (como `pw-loopback`) são controlados por arquivos de PID dedicados (`/tmp/qearon_loopback.pid`) e sinalizados estritamente com `kill -15`, abolindo `pkill` global.
6. **Resiliência e Degradação Graciosa**: Falhas em etapas secundárias (como gravação permanente em disco) geram avisos formais sem impedir a restauração do fluxo de áudio, com códigos de saída POSIX estritos (0=Sucesso, 1=Sintaxe, 2=Hardware).

---

## 2. Mapa de Módulos da AST (`qearon/src/`)

```text
qearon/src/
├── main.zig         # Ponto de entrada, parser de argumentos e despacho com códigos de saída POSIX
├── ui.zig           # Motor ANSI, caixas Unicode e oscilograma espectral
├── i18n.zig         # Dicionário único de internacionalização (PT/EN) com suporte a diretório XDG
├── autofix.zig      # Máquina de estados de reparo dinâmico em 6 etapas sequenciais
├── detector.zig     # Jack Sensing multi-tier: ALSA cget, procfs codec pin-ctls e fallback pw-dump
├── alsa.zig         # Descoberta dinâmica de placa primária, controle de ganho e silenciamento de bleed
├── pipewire.zig     # Resolução dinâmica universal de nós de áudio e índices de rota
├── streams.zig      # Migração transparente de fluxos de clientes em execução
├── tester.zig       # Teste de canal estéreo e calibração de microfone com armazenamento seguro
├── vumeter.zig      # Amostrador PCM em tempo real com cálculo RMS real e visualizador simétrico
├── loopback.zig     # Monitoramento de voz (Sidetone) nativo com isolamento de PID (/tmp)
├── denoise.zig      # Filtro de cancelamento de eco nativo PipeWire com destruição por ID
├── watcher.zig      # Sentinela contínuo de hardware com autofix silencioso em hotplug
├── installer.zig    # Instalador do binário em /usr/local/bin com symlink canônico mic-fix
└── sys.zig          # Executor de subprocessos e pipes com buffer de 4MB e matador de PIDs
```

---

## 3. Fluxo de Execução do Ciclo de Reparo (`autofix`)

O ciclo de reparo automático executa uma máquina de estados linear de 6 etapas:

```text
[Início]
   │
   ├─► [1/6] Jack Sensing Multi-Tier: Audita eventos de kernel ALSA cget 'iface=CARD,name=* Jack',
   │         inspeciona /proc/asound/card*/codec#* (Pin-ctls) e analisa topologia pw-dump.
   │         Identifica conectores frontal ou traseiro com precisão instantânea.
   │
   ├─► [2/6] Calibragem ALSA Dinâmica: Detecta a placa primária não-HDMI em /proc/asound/cards.
   │         Normaliza Master (85%), Front (100%), Headphone (100%).
   │         Muta os canais de playback analógico (Rear Mic, Front Mic) para evitar ruído elétrico.
   │         Define ganho de captura em 80% e Mic Boost em 2 (+20 dB).
   │
   ├─► [3/6] Roteamento PipeWire Dinâmico: Resolve dinamicamente IDs de sink e source analógicos
   │         sem utilizar caminhos PCI estáticos. Configura rotas de hardware no nó da placa de som.
   │
   ├─► [4/6] Migração de Streams: Identifica fluxos ativos de clientes (browsers, jogos, Discord)
   │         e transfere os inputs para o sink analógico ativo sem interrupção de reprodução.
   │
   ├─► [5/6] Persistência: Executa 'alsactl store <card>' para salvar o estado nos arquivos do sistema.
   │
   └─► [6/6] Verificação de Integridade: Emite sinal estéreo de 440 Hz nos canais esquerdo e direito
             (opcionalmente silenciado durante hotplug automático pelo sentinela watcher).
[Conclusão]
```

---

## 4. Integração de Baixo Nível

- **ALSA (Advanced Linux Sound Architecture)**: Descoberta dinâmica de `/dev/snd/controlC*` e leitura de `/proc/asound/cards`. Comunicação direta via `amixer` para calibração de impedância, ganho de pré-amplificação de microfone e chaveamento de canais.
- **PipeWire Graph**: Roteamento dinâmico e inspeção de topologia via `pw-dump`, controle nativo de nós via `wpctl` e criação de sidetone isolado via `pw-loopback` com menos de 1 ms de latência e controle nativo de filtros via `pw-cli`.

---

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
