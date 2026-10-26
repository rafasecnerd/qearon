---
name: "Relatório de Falha / Bug Report"
about: "Relate um defeito de hardware, falha de roteamento ou erro de compilação / Report hardware defect, routing failure, or build error"
title: "[BUG] Descrição concisa da falha / Concise bug description"
labels: ["bug", "triage"]
assignees: ["rafasecnerd"]
---

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software / Software Version: **v0.1.0**

---

> [!IMPORTANT]
> **[PT-BR]** Preencha todas as seções abaixo com o máximo de precisão técnica.  
> **[EN]** Please complete all sections below with technical precision.

---

## 1. Identificação do Ambiente / Environment Details

| Parâmetro / Parameter | Valor Informado / Reported Value |
| :--- | :--- |
| **Distribuição / OS** | [ex: Ubuntu 24.04 / Arch Linux / Debian 12] |
| **Kernel Linux** | [ex: `uname -r`] |
| **Versão do Qearon / Version** | [ex: `v0.1.0`] |
| **Servidor de Som / Audio Server** | [PipeWire / PulseAudio / ALSA Puro] |
| **Placa de Som / Codec** | [ex: Realtek ALC887 / Intel HDA] |

---

## 2. Descrição do Problema / Problem Description

### [PT-BR] Português
Descreva de forma clara e objetiva o comportamento anômalo observado no hardware ou no terminal.

### [EN] English
Clearly describe the unexpected behavior observed across audio hardware or terminal output.

---

## 3. Passos para Reproduzir / Steps to Reproduce

1. **[PT-BR/EN]** Executar o comando / Run command: `qearon ...`
2. **[PT-BR/EN]** Conectar o dispositivo / Connect jack: `...`
3. **[PT-BR/EN]** Observar o resultado / Observe behavior: `...`

---

## 4. Comportamento Esperado / Expected Behavior

### [PT-BR] Português
O que deveria acontecer de acordo com a arquitetura do Qearon e dos mixers ALSA.

### [EN] English
What should have happened according to Qearon specifications and ALSA mixer controls.

---

## 5. Registros de Diagnóstico / Diagnostic Logs

> [!NOTE]
> Anexe a saída dos seguintes comandos para auditoria técnica / Attach the output of the following diagnostic commands:

```bash
# Diagnóstico de nós do Qearon / Qearon state
qearon status

# Registradores físicos do codec ALSA / ALSA hardware codec registers
cat /proc/asound/card0/codec#0 | head -n 50
```

---

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
