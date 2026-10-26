# Guia de Solução de Problemas e Diagnóstico

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software: **v0.1.0**

---

## 1. Matriz de Classificação de Falhas

O motor de diagnóstico classifica as anomalias em quatro vetores operacionais:

| Componente | Sintoma de Falha | Causa Provável | Ação Recomendada |
| :--- | :--- | :--- | :--- |
| **Camada Física (Jack)** | Microfone ou fone ausente | Conector desconectado ou mau contato | Auditar pinos ALSA e eventos via `amixer -c <card> cget iface=CARD,name='* Jack'` |
| **Kernel / ALSA** | Silêncio absoluto ou chiado elétrico | Canal mutado ou retorno analógico ativo no mixer | Executar `qearon autofix` para redefinir registradores da placa primária |
| **Roteamento / PipeWire** | Áudio direcionado à saída errada | Sink padrão incorreto ou nó órfão | Auditar via `qearon status` e reaplicar `qearon autofix` |
| **Loopback / Latência** | Eco excessivo ou processo zumbi | Instância antiga persistente | Interromper de forma isolada via `qearon loopback off` |

---

## 2. Problemas Frequentes e Resoluções

### Problema 1: Chiado Estridente ou Vazamento Analógico (Analog Bleed)
* **Contexto**: Codecs HDA Intel e Realtek ALC887/ALC892/ALC1220 com canais de reprodução analógicos abertos no mixer.
* **Mecanismo**: O circuito somador analógico da placa injeta o sinal do conector P2 de 3.5mm diretamente nos DACs de saída antes de qualquer filtragem digital.
* **Solução Técnica**:
  ```bash
  qearon autofix
  ```
  > [!NOTE]
  > O comando silencia explicitamente os canais `Rear Mic`, `Front Mic` e `Line` na matriz de reprodução (`Playback`), preservando o canal `Capture` ativo no conversor ADC.

### Problema 2: Nível de Microfone Excessivamente Baixo
* **Contexto**: Pré-amplificador de hardware desativado ou ganho de captura atenuado.
* **Mecanismo**: Cápsulas de eletreto e microfones integrados necessitam de amplificação ativa (bias voltage e ganho de entrada).
* **Solução Técnica**:
  1. Verificar o nível RMS em tempo real com o medidor dinâmico:
     ```bash
     qearon vu
     ```
  2. Caso a modulação permaneça abaixo de 10%, recalibrar os canais via `qearon autofix` ou manualmente especificando a placa primária descoberta em `/proc/asound/cards`:
     ```bash
     # Descobrir o índice da placa analógica:
     cat /proc/asound/cards
     
     # Calibrar ganho e pré-amplificação (+20dB):
     amixer -c <card> set 'Capture' 80%
     amixer -c <card> set 'Mic Boost' 2
     ```
  > [!TIP]
  > O valor de `Boost` recomendado é 2 (+20dB). O nível 3 (+30dB) costuma introduzir distorção harmônica e ruído de fundo indesejado.

### Problema 3: Falha de Comunicação com o Servidor PipeWire
* **Contexto**: Daemon de áudio inativo ou socket de comunicação inacessível.
* **Mecanismo**: Comandos do Qearon falham durante a consulta da topologia do grafo de nós.
* **Solução Técnica**:
  1. Verificar o estado dos serviços de usuário:
     ```bash
     systemctl --user status pipewire.service
     ```
  2. Reiniciar os serviços se necessário:
     ```bash
     systemctl --user restart pipewire wireplumber
     ```
  > [!IMPORTANT]
  > O Qearon opera de forma autônoma e não depende de `pipewire-pulse` para reparo de hardware e loopback de baixa latência.

---

## 3. Rotina de Diagnóstico Avançado

Quando a recuperação automática não surtir efeito, execute a triagem manual passo a passo:

1. **Inspecionar a Placa Primária e Codecs Ativos**:
   ```bash
   cat /proc/asound/cards
   cat /proc/asound/card*/codec#* | grep -E "Codec|Pin Complex" | head -n 30
   ```
2. **Auditar Controles do Mixer ALSA**:
   ```bash
   amixer -c 0 scontents
   ```
3. **Monitorar o Grafo PipeWire em Tempo Real**:
   ```bash
   pw-top
   ```

---

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
