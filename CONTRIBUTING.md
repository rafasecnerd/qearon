# Diretrizes de Contribuição / Contributing Guidelines

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Versão do Software / Software Version: **v0.1.0**

---

## [PT-BR] Português

Agradecemos o interesse em contribuir com o **Qearon**. Este projeto preza pela simplicidade arquitetural, purismo técnico em linguagem Zig e ausência de dependências runtime externas desnecessárias.

### 1. Princípios de Engenharia
- **Linguagem Padrão**: Zig (0.13.0+). Não introduza bibliotecas externas ou frameworks pesados.
- **Estilo de Código**: Padrão 1TBS (*One True Brace Style*), indentação de 4 espaços, nomes em `snake_case` para funções/variáveis e `PascalCase` para structs/tipos.
- **Comentários de Código**: Zero comentários inline ou prolixos no código-fonte. A documentação vive exclusivamente nos arquivos técnicos em `docs/`.
- **Internacionalização Obrigatória**: Qualquer string visível ao operador deve ser registrada em `src/i18n.zig`. Nenhuma string hardcoded é permitida nos módulos executáveis.
- **Tratamento de Falhas**: Aplique sempre degradação suave com `errdefer` ou fallbacks controlados. Nunca cause pânico (`panic`) sem justificativa de segurança de memória.

### 2. Fluxo de Desenvolvimento
1. Crie um fork do repositório.
2. Crie uma branch nomeada conforme o padrão semântico: `feature/nome-recurso` ou `fix/nome-correcao`.
3. Garanta que o binário compila perfeitamente sem advertências:
   ```bash
   cd qearon
   zig build
   ```
4. Atualize a documentação técnica espelhada em `docs/pt-br/` e `docs/en/`.
5. Abra um Pull Request utilizando o modelo padrão fornecido em `.github/pull_request_template.md`.
6. **Reconhecimento na Galeria do README**: Após a aprovação e integração do seu Pull Request, você ganha o direito de colocar sua foto/avatar na vitrine de colaboradores do `README.md` ao lado da autora Rafaela De Lima! Basta incluir sua imagem em `assets/` e atualizar a tabela.

---

## [EN] English

Thank you for your interest in contributing to **Qearon**. This project prioritizes architectural minimalism, pure Zig implementation, and zero unnecessary runtime dependencies.

### 1. Engineering Principles
- **Target Language**: Zig (0.13.0+). Do not introduce external libraries or heavy dependencies.
- **Code Style**: 1TBS (One True Brace Style), 4-space indentation, `snake_case` for functions/variables, and `PascalCase` for structs/types.
- **Source Comments**: Zero inline or verbose comments in source code. Documentation lives strictly inside the technical documentation repository under `docs/`.
- **Mandatory Internationalization**: Any operator-facing string must be declared within `src/i18n.zig`. Hardcoded strings in functional modules are prohibited.
- **Error Handling**: Implement graceful degradation using `errdefer` or defensive fallbacks. Never invoke unhandled panics.

### 2. Development Workflow
1. Fork the repository.
2. Create a branch adhering to semantic naming: `feature/feature-name` or `fix/fix-name`.
3. Verify that the codebase builds cleanly without warnings:
   ```bash
   cd qearon
   zig build
   ```
4. Update the mirrored technical documentation under both `docs/pt-br/` and `docs/en/`.
5. Open a Pull Request adhering to `.github/pull_request_template.md`.
6. **Showcase Recognition on README**: Once your Pull Request is reviewed and merged, you are entitled to place your avatar/photo in the contributor showcase table in `README.md` right next to the creator Rafaela De Lima! Simply add your image to `assets/` and update the table.

---

Desenvolvido por / Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
