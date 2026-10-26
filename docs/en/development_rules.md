# Engineering and Development Standards - Qearon (EN)

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))  
Software Version: **v0.1.0**

---

## 1. Code Style and Conventions

1. **1TBS (One True Brace Style)**:
   - Opening curly braces on the same line as functions, structs, `if`, `else`, `while`, and `switch` statements.
   - Strict 4-space indentation (no mixed tabs).
2. **Vertical and Sequential Layout**:
   - Constants and package imports positioned strictly at the top of the file.
   - Helper routines ordered sequentially following execution flow.
3. **Self-Documenting Code (Zero In-Code Noise)**:
   - Zig codebase must remain expressive and self-explanatory through rigorous identifier naming.
   - In-source redundant comments are prohibited; architectural documentation is centralized under `docs/`.
4. **Strict String Isolation (i18n)**:
   - Zero hardcoded user-facing strings across implementation modules.
   - All text must reside within `Strings` struct in `src/i18n.zig` and accessed through `tr()`.
5. **Non-Destructive Operations & Process Isolation**:
   - System-wide blanket commands like `pkill` are strictly prohibited.
   - Detached background subprocesses must track their PID in `/tmp/<component>.pid` and be terminated explicitly via POSIX `kill -15 <pid>`.
6. **Dynamic Hardware Topology**:
   - Zero hardcoded PCI device strings or static ALSA card assumptions. Hardware paths and endpoints must be dynamically discovered via `/proc/asound` and `pw-dump`.

---

## 2. Memory Management in Zig

- **Zero Garbage Collection**: Qearon operates with deterministic manual memory semantics.
- **Explicit Allocator Ingestion**: Functions that dynamically allocate memory must accept `allocator: std.mem.Allocator`.
- **Mandatory RAII Pattern (`defer`)**: Every dynamic allocation or resource acquisition must be followed immediately by a corresponding `defer allocator.free(...)` or resource closing logic.
- **Strict Leak Detection**: Application entry point encapsulates execution in `std.heap.GeneralPurposeAllocator` to guarantee zero memory leaks before terminating with `std.process.exit`.

---

## 3. Commit Guidelines and Versioning

The codebase enforces **Conventional Commits**:
- `feat(...)`: New capability or subsystem feature.
- `fix(...)`: Hardware routing, mixer, or runtime bug fix.
- `refactor(...)`: Internal code improvement without altering external behavior.
- `style(...)`: Visual UI adjustments, ANSI formatting, or box drawing changes.
- `docs(...)`: Documentation additions or synchronization updates.

Every engineering iteration must conclude with a local Git commit to preserve auditability and clean history.

---

## 4. Contributor Recognition Policy

Any community member whose contribution (bug fix, architectural optimization, or documentation refinement) is approved and merged through a Pull Request earns the right to have their profile picture/avatar displayed in the contributor showcase of the root `README.md`, positioned side by side with creator Rafaela De Lima. To claim this slot:
1. Submit your image asset into the `assets/` directory.
2. Add a new column or cell entry within the contributor showcase table in `README.md`.

---

Developed by: **[Rafaela De Lima (@rafasecnerd)](https://www.instagram.com/rafasecnerd)** ([TikTok](https://www.tiktok.com/@rafasecnerd) | [Instagram](https://www.instagram.com/rafasecnerd) | [YouTube](https://www.youtube.com/@rafasecnerd))
