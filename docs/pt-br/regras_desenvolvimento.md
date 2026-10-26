# Regras de Engenharia e Desenvolvimento - Qearon (PT-BR)

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software: **v0.1.0**

---

## 1. Padrões de Código e Estilo

1. **Padrão 1TBS (One True Brace Style)**:
   - Chaves de abertura na mesma linha de declaração de funções, structs, blocos `if`, `else`, `while` e `switch`.
   - Indentação estrita com 4 espaços (sem tabs misturados).
2. **Layout Vertical e Sequencial**:
   - Declaração de constantes e variáveis sempre no topo do arquivo.
   - Funções auxiliares declaradas na ordem linear de chamada.
3. **Código Autoexplicativo (Sem Comentários Redundantes)**:
   - O código-fonte em Zig deve ser limpo e autoexplicativo através de nomenclatura precisa de funções e variáveis.
   - Comentários desnecessários ou redundantes dentro do código são estritamente evitados; a documentação de arquitetura é mantida na pasta `docs/`.
4. **Isolamento Absoluto de Strings (i18n)**:
   - Nenhuma string visível ao usuário deve ser inserida diretamente no código dos módulos.
   - Todo texto deve ser declarado na struct `Strings` em `src/i18n.zig` e consumido via `tr()`.
5. **Operações Não-Destrutivas e Isolamento de Processos**:
   - É terminantemente proibido o uso de `pkill` global ou comandos destrutivos cégos.
   - Todo subprocesso desacoplado deve gravar seu PID em `/tmp/<componente>.pid` e ser finalizado pontualmente via `kill -15 <pid>`.
6. **Universalidade Sem Hardcodeds**:
   - Proibido codificar caminhos estáticos de dispositivos PCI ou índices fixos de placas ALSA. Toda topologia deve ser inspecionada dinamicamente via `/proc/asound` e `pw-dump`.

---

## 2. Gerenciamento de Memória em Zig

- **Sem Coletor de Lixo (No GC)**: O Qearon não utiliza garbage collector nem alocação oculta.
- **Alocador Explícito**: Todas as funções que alocam buffers recebem um `allocator: std.mem.Allocator`.
- **Liberação Obrigatória (`defer`)**: Toda alocação deve possuir seu respectivo `defer allocator.free(...)` ou encerramento de recurso imediatamente subsequente.
- **Detecção Rigorosa de Vazamentos (`GeneralPurposeAllocator`)**: O executável utiliza o GPA do Zig no `main.zig` garantindo auditoria de vazamento zero antes da saída do processo (`std.process.exit`).

---

## 3. Diretrizes de Commits e Versionamento

O repositório adota o padrão **Conventional Commits**:
- `feat(...)`: Adição de nova capacidade ou comando.
- `fix(...)`: Correção de falha de hardware, rota ou erro de execução.
- `refactor(...)`: Reestruturação de código sem alteração de comportamento externo.
- `style(...)`: Ajustes visuais de formatação ANSI ou alinhamento.
- `docs(...)`: Alteração ou inclusão de documentação técnica.

Cada rodada de trabalho deve obrigatoriamente concluir com commit local no Git para garantir histórico de auditoria e integridade de backup.

---

## 4. Política de Reconhecimento de Contribuidores

Todo membro da comunidade que tiver uma contribuição (correção de defeito, melhoria arquitetural ou atualização documental) aceita e integrada via Pull Request adquire o direito de exibir sua imagem de perfil/avatar na vitrine de colaboradores do `README.md` principal, posicionada lado a lado com a foto da criadora Rafaela De Lima. Para isso:
1. Submeta seu arquivo de imagem para o diretório `assets/`.
2. Adicione uma nova coluna ou célula na tabela de colaboradores do arquivo `README.md`.

---

Desenvolvido por: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
