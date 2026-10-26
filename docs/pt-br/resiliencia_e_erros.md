# Resiliência, Degradação Suave e Tratamento de Erros

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software: **v0.1.0**

---

## 1. Filosofia de Resiliência

> *"Programadores não são aqueles que escrevem código perfeito, mas aqueles que sabem como corrigir erros."*  
> — **[Barbara Liskov](https://pt.wikipedia.org/wiki/Barbara_Liskov)** (Vencedora do Prêmio Turing e pioneira da Ciência da Computação)

O Qearon opera sob o princípio da **degradação graciosa** (graceful degradation) e **não-destrutividade**. Falhas em subsistemas periféricos (como ausência de servidor PulseAudio ou daemon de persistência) não interrompem o fluxo central de reparo de hardware do ALSA ou monitoramento.

```
+-------------------------------------------------------------+
|                     Comando Solicitado                      |
+-------------------------------------------------------------+
                              |
              +---------------+---------------+
              |                               |
       [Sucesso Direto]              [Falha em Subsistema]
              |                               |
    [Retorno de Sucesso]             [Ativação de Fallback]
                                              |
                                   +----------+----------+
                                   |                     |
                            [Degradação Suave]   [Alerta Não Fatal]
```

---

## 2. Estratégias de Recuperação por Módulo

### 2.1 Subsistema ALSA (`src/alsa.zig`)
* **Descoberta Dinâmica de Placas**: Em vez de fixar a placa `0`, inspeciona `/proc/asound/cards` dinamicamente para selecionar a placa de áudio analógica primária, ignorando saídas HDMI/NVidia quando apropriado.
* **Tolerância a Controles Inexistentes**: Controles de mixer variam entre placas-mãe (ex: ausência de controle `Front` ou `Headphone`). Erros em controles opcionais são ignorados silenciosamente sem abortar a sequência de restauração do canal `Master` ou `Capture`.
* **Garantia**: O microfone e a saída principal são sempre restabelecidos com ganho calibrado.

### 2.2 Subsistema de Roteamento PipeWire (`src/pipewire.zig`)
* **Eliminação de IDs Hardcoded**: Sinks, sources e índices de rota de hardware são resolvidos dinamicamente em tempo de execução via `pw-dump`, tornando o Qearon universal entre diferentes placas, barramentos e distribuições.
* **Independência de PulseAudio**: Operações degradam suavemente para as ferramentas nativas do PipeWire (`pw-cli`, `wpctl`, `pw-loopback`, `pw-dump`).
* **Garantia**: O sistema nunca gera falhas fatais por recusa de conexão em soquetes PulseAudio legados.

### 2.3 Subsistema de Loopback em Tempo Real (`src/loopback.zig`)
* **Isolamento de Processos por PID**: O PID do processo `pw-loopback` desacoplado é registrado no diretório seguro de runtime do usuário (`XDG_RUNTIME_DIR/qearon_loopback.pid`, com fallback em `/tmp`).
* **Término Seguro e Específico**: O encerramento via `qearon loopback off` envia `kill -15` exclusivamente para o PID registrado, eliminando o comando destrutivo `pkill -f pw-loopback` que afetava outros softwares.

### 2.4 Subsistema de Cancelamento de Ruído (`src/denoise.zig`)
* **Rastreamento de ID Nativo**: O ID do nó de filtro carregado via PipeWire é capturado e gravado no diretório seguro de runtime do usuário (`XDG_RUNTIME_DIR/qearon_denoise.pw_id`, com fallback em `/tmp`).
* **Destruição Determinística**: A desativação executa `pw-cli destroy <id>` diretamente no subsistema nativo do PipeWire, com fallback transparente para descarregamento via PulseAudio.

---

## 3. Códigos de Saída do Sistema (POSIX)

| Código | Identificador | Significado Técnico |
| :---: | :--- | :--- |
| `0` | `SUCCESS` | Execução concluída sem falhas ou com degradações tratadas |
| `1` | `ARGUMENT_ERROR` | Parâmetros de linha de comando inválidos ou comando não reconhecido |
| `2` | `HARDWARE_UNAVAILABLE` | Nenhuma placa de som física detectada no subsistema ALSA ou falha crítica |

---

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
