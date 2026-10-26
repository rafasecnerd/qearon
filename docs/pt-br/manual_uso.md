# Manual de Operação e Uso - Qearon (PT-BR)

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software: **v0.1.0**

---

## 1. Visão Geral de Operação

O **Qearon** é executado diretamente via terminal (`qearon <comando> [opcao]` ou através do alias `mic-fix <comando> [opcao]`). Todos os comandos possuem resposta determinística em milissegundos e suportam tanto a sintaxe em Português quanto os termos canônicos em Inglês, retornando códigos de terminação padrão POSIX (0 para sucesso, 1 para sintaxe, 2 para falhas de hardware).

---

## 2. Catálogo Completo de Comandos

### 2.1 Reparo e Solução de Problemas

- `qearon reparar` *(ou `qearon autofix`)*  
  Executa a rotina sequencial completa de diagnóstico: Jack Sensing multi-tier, calibração dinâmica ALSA, eliminação de bleed elétrico, resolução dinâmica de rotas PipeWire e teste acústico estéreo.
- `qearon fone` *(ou `qearon headset`)*  
  Ativa dinamicamente o perfil analógico estéreo de reprodução e microfone, direcionando o fluxo para os conectores P2/TRRS sem assumir caminhos PCI estáticos.
- `qearon hdmi`  
  Descobre dinamicamente o sink HDMI da GPU e transfere a saída padrão de reprodução para a interface digital (TVs ou monitores com áudio).

### 2.2 Ajustes de Microfone e Voz

- `qearon vu`  
  Abre o medidor dinâmico com **cálculo matemático RMS** ($\sqrt{\frac{1}{N}\sum x_i^2}$) amostrado diretamente de streams PCM S16LE. Renderiza barra simétrica dual-wing (`<[ ||||.... ▲ ....|||| ]>`) com gradiente ANSI, leitura de pico em porcentagem e diagnóstico de status (SILENCE, LOW, OPTIMAL, CLIPPING). Encerre com `Ctrl+C`.
- `qearon retorno ligar` *(ou `qearon loopback on`)*  
  Ativa o monitoramento em tempo real (Sidetone) com menos de 1 ms de latência via `pw-loopback`. O identificador do processo é isolado em `/tmp/qearon_loopback.pid`.
- `qearon retorno desligar` *(ou `qearon loopback off`)*  
  Desativa o processo isolado via sinal POSIX `kill -15`, sem afetar outras instâncias de loopback do sistema operacional.
- `qearon ruido ligar` *(ou `qearon denoise on`)*  
  Ativa o módulo de cancelamento de eco acústico e supressão de ruído ativo (`libpipewire-module-echo-cancel`), registrando o ID nativo do módulo PipeWire.
- `qearon ruido desligar` *(ou `qearon denoise off`)*  
  Destrói o nó nativo diretamente no PipeWire (`pw-cli destroy <id>`) e restaura a captura analógica direta.

### 2.3 Diagnóstico e Testes

- `qearon testar-som` *(ou `qearon test-sound`)*  
  Emite sinais senoidais puros de 440 Hz separadamente no canal esquerdo e no canal direito para validação de fase e integridade dos fones.
- `qearon testar-mic` *(ou `qearon test-mic`)*  
  Grava uma amostra acústica de 2 segundos do microfone no diretório runtime seguro (`XDG_RUNTIME_DIR` ou `/tmp`) e reproduz imediatamente nos fones de ouvido.
- `qearon status`  
  Exibe tabela detalhada de conectores físicos (Line Out, Rear Mic, Headphone, Front Mic), estado dos mixers de hardware ALSA e topologia ativa de áudio no PipeWire de forma filtrada e sem cabeçalhos duplicados.

### 2.4 Sistema e Configurações

- `qearon vigiar` *(ou `qearon watch`)*  
  Executa o serviço sentinela contínuo em segundo plano. Detecta eventos de conexão/desconexão física de conectores P2 via Jack Sensing e dispara a autocorreção dinâmica de forma **silenciosa** (sem emissão intrusiva de 440 Hz).
- `qearon instalar` *(ou `qearon install`)*  
  Compila o executável em modo otimizado de produção (`ReleaseFast`), instalando o binário em `/usr/local/bin/qearon` e criando o symlink canônico `/usr/local/bin/mic-fix`.
- `qearon idioma pt` | `qearon idioma en`  
  Altera a preferência de idioma da interface e persiste no padrão XDG em `~/.config/qearon/lang` (com fallback em `/tmp/.qearon_prefer`).
- `qearon ajuda` *(ou `qearon help`)*  
  Exibe o guia de uso e lista de comandos.

---

## 3. Códigos de Saída do Processo (POSIX Standard)

| Código | Significado | Causa Comum |
| :---: | :--- | :--- |
| `0` | **Sucesso** | Operação concluída com êxito. |
| `1` | **Erro de Sintaxe** | Comando ou subcomando desconhecido/inválido. |
| `2` | **Falha de Hardware/Driver** | Codec ALSA inacessível ou PipeWire indisponível. |

---

## 4. Exemplos Práticos de Uso

```bash
# 1. Recuperar som e microfone de forma autônoma:
qearon reparar

# 2. Testar sensibilidade e modulação RMS da voz no terminal:
qearon vu

# 3. Regular a sensibilidade do microfone ouvindo seu próprio retorno com PID isolado:
qearon retorno ligar
# (após falar e calibrar)
qearon retorno desligar

# 4. Ativar cancelamento de eco nativo:
qearon ruido ligar

# 5. Iniciar sentinela com reparo silencioso em segundo plano:
qearon vigiar
```

---

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
