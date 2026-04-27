# CLAUDE.md - FindBigFiles (FileSizer)

## Project Overview

**Name:** FindBigFiles / FileSizer  
**Type:** macOS App (SwiftUI)  
**Description:** Native macOS app for finding large files on disk. Features async scanning, file management (move to Trash, Reveal in Finder), scan history, and export to CSV/JSON.  
**Owner:** @polidisio  

## Tech Stack

- **Language:** Swift 5.9+
- **Framework:** SwiftUI + NavigationSplitView
- **Persistence:** SQLite.swift (scan history)
- **Min macOS:** 13.0 (Ventura)
- **Architecture:** MVVM
- **Build System:** XcodeGen (project.yml)

## Quick Start

```bash
# Generate Xcode project (requires XcodeGen)
xcodegen generate

# Open in Xcode
open FileSizer.xcodeproj
# or
open BigFiles.xcodeproj

# Build (Cmd+R)
```

## File Structure

```
FindBigFiles/
├── FileSizer/ (also BigFiles.xcodeproj)
│   ├── App/                     # App entry point
│   ├── Models/                 # ScannedFile, ScanProfile, ScanResult
│   ├── ViewModels/             # MVVM view models
│   ├── Views/                  # SwiftUI views
│   ├── Services/               # FileScanner, ExclusionManager, FinderComments
│   ├── Persistence/            # SQLite.swift for history
│   └── Resources/              # Info.plist, entitlements, assets
├── project.yml
├── README.md
└── CLAUDE.md
```

## Features

- ✅ Native SwiftUI interface
- ✅ Async directory scanning (non-blocking UI)
- ✅ File management: Move to Trash, Reveal in Finder
- ✅ Scan history persistence
- ✅ Export results (CSV/JSON)
- ✅ Finder Comments (read/write)
- ✅ App Store ready (Sandboxed + Hardened Runtime)

## Architecture

### Pattern: MVVM
- **Model:** ScannedFile, ScanProfile, ScanResult
- **View:** SwiftUI NavigationSplitView
- **ViewModel:** Scan state management
- **Service:** FileScanner, ExclusionManager, FinderComments

### Data Persistence
- SQLite.swift for scan history
- UserDefaults for settings

## Conventions

- SwiftUI NavigationSplitView for sidebar navigation
- Async/await for file scanning
- Exclusion patterns: `node_modules`, `.git`, `Caches`

## Testing

```bash
# Build via xcodegen
xcodegen generate
xcodebuild -project FileSizer.xcodeproj -scheme FileSizer -configuration Debug build
```

## Related Projects

- **[bigfiles](https://github.com/polidisio/bigfiles)** - Python CLI version

## Important Rules

### ✅ Always Do
- Test with large directories (>100k files)
- Respect filesystem exclusions

### ❌ Never Do
- Scan system directories without user consent

## Resources

- Token optimization tips: `shared/claude-optimization-tips.md` (Obsidian Vault)

---

**Owner:** Jose Maudisio (@polidisio)  
**Last updated:** 2026-04-24

---

---

## Workflow

### Para tareas simples
Sé directo: "Añade validación al form" — no necesitas explicar contexto.

### Para tareas complejas (>3 pasos)
1. Agent propone plan primero
2. Usuario confirma
3. Agent ejecuta
4. Agent verifica con tests

### Para cada tarea
1. **Plan** → Si son >3 pasos, escribir en `tasks/todo.md`
2. **Verify** → Confirmar antes de cambios grandes
3. **Execute** → Cambio más pequeño posible
4. **Test** → Ejecutar tests, verificar regression
5. **Document** → Actualizar si es necesario

---

## Code Quality

### SIEMPRE
- Código legible y mantenible
- Seguir convenciones del proyecto
- DRY — no duplicar lógica
- Validar input antes de procesar

### NUNCA
- Hardcodear credenciales o tokens
- "Hacky fixes" sin justificación
- Duplicar código sin razón
- Commits sin mensaje descriptivo

---

## Security

- **NUNCA hardcodear** credenciales — usar environment variables
- **NUNCA exponer** tokens en logs o errores
- **Validar input** antes de procesar
- Si hay secrets, usar `.env` y nunca commitearlo

---

## Self-Improvement

### Si cometes un error
1. Documentar en `lessons.md` — qué salió mal, por qué, cómo evitarlo
2. Actualizar este archivo si la convención no estaba clara
3. No repetir

### Si descubres algo útil
- Documentar en notas del proyecto
- Compartir con Jose si es relevante

---

## Token Optimization

### Hacer
- Agrupar múltiples requests en uno
- Editar en vez de reply (menos historial)
- Nuevo tema = nueva conversación
- Planificar en chat, construir en workspace

### Evitar
- Subir carpetas enteras — solo archivos necesarios
- Múltiples prompts cortos seguidos
- Usar Opus para tareas simples
- Mantener contexto irrelevante

**Budget:** ~88% de tokens en conversaciones largas = solo historial. Mantenerlo limpio.

---

## Resources

**Obsidian Vault:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Saraiba/`

| Recurso | Ubicación en Vault |
|---------|---------------------|
| Best practices | `shared/coding-best-practices.md` |
| Optimization tips | `shared/claude-optimization-tips.md` |
| Skills docs | `shared/openclw-skills.md` |
| Guía coding agents | `shared/guia-coding-agents.md` |

---

## Contact

**Jose Maudisio** — @polidisio
**Issues:** Abrir en GitHub o preguntar en Telegram
