# Roadmap: AIHelperMacOS

Этот документ описывает план разработки AIHelperMacOS для большой команды с максимальной параллелизацией задач, непрерывной интеграцией и промежуточными сборками для тестирования.

## WWDC 2025: Apple Platform Updates

- SwiftUI 6: улучшенные Layout-протоколы, ChartsKit, lockable fields, новые Material-стили.
- Metal 4: расширенные RayTracing API, GPU-ускоренный ML Compute, Swift шейдеры.
- macOS 26/iOS 26/watchOS 26: новые SwiftData, async DataStore, Live Activities на Mac, улучшения AsyncImage, OutlineGroup.
- Xcode 17: Swift Concurrency 2.0, Observation & macros, Package Plugins для SPM.

## Team & Parallelization

- Команда разбивается по фичам и подтаскам:
  - feature/persistence (UserDefaults)
  - feature/import (JSON/YAML)
  - feature/local-llm-runner (LlamaRunner интеграция)
  - feature/local-llm-ui (UI для моделей)
  - feature/auto-mode (логика выбора)
  - feature/codegen-core (структура папок)
  - feature/codegen-ui (ProgressView, отмена)
  - feature/cloud-llm (HTTP/API, Keychain, n8n)
  - feature/theme-polish (SwiftUI6 материал)
  - feature/templates (редактор шаблонов)
+### Parallel Streams for Betas 10–13
+- Team CrossPlatform (2–3 devs): Beta 10 – Cross-Platform Support (iOS26, watchOS26, Catalyst)
+- Team History (2 devs): Beta 11 – Chat History & Search (SwiftData истории и поиск)
+- Team Automation (2 devs): Beta 12 – Automation Workflows (n8n/MCP webhooks)
+- Team Scaffold (2 devs): Beta 13 – Code Scaffolding (SPM Plugin/Swift Macro)
 
- Параллельно работают 3–4 подкоманды, каждая выпускает свою Beta-сборку.
+Параллельно работают 4 команды, каждая ведёт свой поток по расписанию выше.

## CI/CD & GitHub Integration

1. Создать репозиторий на GitHub: `pablito/AIHelperMacOS`.
2. Локальная настройка:
   ```bash
   git init
   git remote add origin https://github.com/pablito/AIHelperMacOS.git
   git add .
   git commit -m "Initial scaffold"
   git push -u origin main
   ```
3. Добавить workflow `.github/workflows/ci.yml`:
   ```yaml
   name: CI
   on: [push, pull_request]
   jobs:
     build:
       runs-on: macos-latest
       steps:
         - uses: actions/checkout@v3
         - name: Set up Swift
           uses: fwal/setup-swift@v1
           with:
             swift-version: '5.10'
         - name: Build
           run: swift build --configuration debug
         - name: Run Tests
           run: swift test
         - name: Archive App
           run: |
             mkdir build
             cp .build/debug/AIHelperMacOS build/AIHelperMacOS
             zip -j build/AIHelperMacOS-${{ github.sha }}.zip build/AIHelperMacOS
         - name: Upload artifact
           uses: actions/upload-artifact@v3
           with:
             name: AIHelperMacOS-${{ github.sha }}
             path: build/AIHelperMacOS-${{ github.sha }}.zip

     notify:
       needs: build
       runs-on: ubuntu-latest
       if: success()
       steps:
         - name: Send email notification
           uses: dawidd6/action-send-mail@v3
           with:
             server_address: ${{ secrets.SMTP_HOST }}
             server_port: ${{ secrets.SMTP_PORT }}
             username: ${{ secrets.SMTP_USER }}
             password: ${{ secrets.SMTP_PASS }}
             subject: 'AIHelperMacOS Build ${{ github.sha }} Success'
             to: 'pavelr7@gmail.com'
             from: 'ci@aihelper.local'
             body: 'Intermediate build is ready: see artifact AIHelperMacOS-${{ github.sha }}.zip'
   ```
4. Добавить секреты в GitHub: `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`.

## Feature Roadmap (Beta Releases)

### Completed Betas (Days 1–7)
1. **Persistence & Settings** — Beta 1 (Day 1)
2. **Import Roadmap** — Beta 2 (Day 2)
3.1 **Local Models (Runner)** — Beta 3.1 (Day 2)
3.2 **Local Models (UI)** — Beta 3.2 (Day 3)
4. **Auto Mode & Streaming** — Beta 4 (Day 3)
5. **Cloud LLM & n8n** — Beta 5 (Day 4)
6. **Code Generation Core** — Beta 6 (Day 4)
7. **Code Generation UI** — Beta 7 (Day 5)
8. **Theme & SwiftUI6 Polish** — Beta 8 (Day 5)
9. **Templates & SwiftData** — Beta 9 (Day 6)
10. **Code Scaffolding** — Beta 13 (Day 7)

### Upcoming Betas (Days 7–8)
11. **Cross-Platform Support** — Beta 10 (Target Day 7)
    - iOS 26, iPadOS 26, watchOS 26, HomePod OS 26, Catalyst
12. **Chat History & Search** — Beta 11 (Target Day 7)
    - Сохранение истории чатов в SwiftData, поиск, экспорт
13. **Automation Workflows** — Beta 12 (Target Day 8)
    - Интеграция n8n/MCP, webhook, локальные и облачные сценарии

**Note:** следующий приоритет — кроссплатформенная сборка, затем история чатов и автоматизация. Каждый этап займёт 1 полный рабочий день.

## Next Steps

1. Назначить подзадачи и подкоманды.
2. Настроить CI/CD и секреты (email, Telegram).
3. Запустить первые три Beta-параллельно.
4. Ежедневно выпускать новую Beta.
5. Вести ежедневный апдейт и уведомления в почту/Telegram.

## Optimization Proposals
- Use Swift macros for code generation to reduce boilerplate.
- Develop an SPM plugin to automate scaffolding from the command line.
- Integrate code coverage metrics into CI for quick feedback.
- Enable build caching and distributed caching (xcbuild, IceCream) to speed up builds.
- Leverage GitHub Codespaces or Dev Containers for consistent dev environments.
- Use Sourcery meta-programming for generating repetitive code patterns.
- Enforce code style and linting via SwiftLint/SwiftFormat in CI.
- Implement mock data and service generation for faster UI previews.
- Integrate snapshot testing for UI components in the CI pipeline.
- Parallelize CI jobs across platforms and configurations in matrix builds.
- Use Apple's FoundationModels and Xcode AI to assist in coding and refactoring.
- Enable hot-reload with `swift run --watch` for rapid feedback during development.
- Provide a searchable snippet library within the app for common code patterns.
- Support a DSL or template language for defining file and folder structures.
- Offer editor plugins for VSCode and JetBrains IDEs for cross-editor support.
- Embed real-time linting and error highlighting in the code editor UI.
- Integrate Sentry or Crashlytics for automatic crash reporting in beta builds.
- Automate dependency updates with Dependabot or Renovate.
- Generate semantic version tags and automated changelogs on release.
- Publish DocC documentation site automatically from code comments.
- Add an AI-driven code review bot to comment on pull requests.
- Provide real-time collaboration features (similar to Live Share) for pair programming.
- Capture development sessions with screen recording presets.
- Build a dashboard for code metrics (complexity, coverage, performance).
- Integrate Instruments performance profiles directly into the app.
- Show memory, CPU, and GPU usage graphs in-app for inference tasks.
- Monitor network requests and responses in a built-in inspector.
- Display model size, token utilization, and inference time statistics.
- Offer in-app model conversion and quantization tools.
- Support batch inference and multi-threaded/multi-GPU execution.
- Visualize Metal shader graphs and performance counters for GPU tasks.
- Provide a SwiftData entity inspector and query builder interface.
- Include a migration assistant for SwiftData schema changes.
- Offer JSON/YAML editor with schema validation and error feedback.
- Support JSON schema generation from model definitions.
- Allow sharing code snippets or templates via GitHub Gist directly.
- Export projects and artifacts to ZIP or artifact repositories.
- Support Docker-based local services for consistent backend environments.
- Include built-in REST, SSE, WebSocket, and GraphQL API client UIs.
- Record and replay HTTP/S traffic within the app for debugging.
- Implement OAuth2 and API key management UI for secure integrations.
- Integrate with cloud provider SDKs (AWS, GCP, Azure) for S3, Lambda, etc.
- Provide Terraform, Ansible, and Kubernetes YAML snippet generators.
- Generate shell scripts and CI pipeline definitions automatically.
- Offer a cron scheduler UI for testing scheduled workflows locally.
- Use file-system watchers to auto-refresh templates and code snippets.
- Record and replay UI actions as macros for repetitive tasks.
- Implement a command palette (like VSCode) for quick actions.
- Provide global search (file, symbol, TODO) with fuzzy matching.
- Include file rename, refactoring, and batch operations on the file system.
- Embed Git history, diff viewer, and change annotations in the UI.
- Spell-check code comments and markdown docs in-context.
- Include a live Markdown preview with scrolling sync.
- Automatically generate and publish API docs using DocC.
- Offer interactive tutorials and onboarding wizards within the app.
- Provide settings import/export and shareable configurations.
- Add a feedback form for users to report issues or request features.
- Implement telemetry opt-in for anonymous usage analytics.
- Display usage stats and beta build feedback dashboards.
- Integrate unit and UI test generators based on templates.
- Provide a fuzz testing harness for model input validation.
- Include accessibility audit tools and VoiceOver testing presets.
- Generate automated snapshots for dark/light modes and multiple devices.
- Overlay pixel grids and rulers for UI alignment testing.
- Offer code style profile import/export for team consistency.
- Allow customizing keyboard shortcuts and touch bar actions.
- Support multi-window/workspace management in macOS version.
- Provide side-by-side diff and merge tools for file conflicts.
- Offer quick export of UI previews to assets catalog.
- Auto-generate asset variants (light/dark, sizes) from single SVG.
- Integrate music control and audio alerts for long-running tasks.
- Support HomePod Handoff and AirPlay for UI previews.
- Provide a unified notification center integration for build and workflow statuses.
- Include a bottom panel console with filters and search.
- Offer a plugin marketplace for third-party extensions.
- Provide a REST API to control the app remotely for automation.
- Integrate with Apple Shortcuts for custom automation workflows.
- Include a built-in SQLite viewer for SQLite-backed data.
- Provide in-app database migration rollback and versioning.
- Offer a playground-like scratchpad for experimenting with code snippets.
- Support copying code previews in various markup formats (Markdown, HTML).
- Include a productivity timer and focus mode to minimize distractions.
- Provide an integrated calendar view for scheduling CI runs.
- Offer a TODO/task list manager tied to roadmap items.
- Support importing/exporting roadmap tasks between projects.
- Provide notifications via Telegram, Slack, Email when builds/tests finish.
- Allow customizing templates via GUI or code definitions.
- Integrate live chat with AI assistant inside the app for contextual help.

## 100 Must-Have Features for Consideration
- Dark Mode override per view
- Dynamic Font Scaling (Dynamic Type)
- Multilingual Localization (RU/EN/ES/UA)
- Custom Theme Editor
- ChartKit Integration
- Lockable Fields in Forms
- OutlineGroup Components
- Live Activities Support
- Widgets (iOS/macOS/watchOS)
- Siri Shortcuts Integration
- HomePod Voice Control
- Clipboard Snippet Library
- Undo/Redo Stack
- Code Snippet Insertion
- Template Marketplace
- Code Diff Viewer
- Inline Error Highlighting
- Code Folding in Previews
- AI-assisted Refactoring
- Git Integration UI
- Branch Switching UI
- Pull Request Creation UI
- CI Status Indicator
- Real-time Collaboration
- Pair Programming Mode
- Screen Recording Tool
- Code Metrics Dashboard
- Coverage Report UI
- Performance Profiler (Instruments)
- Memory Usage Monitor
- CPU/GPU Usage Monitor
- Network Traffic Inspector
- Model Size & Token Stats
- Local Model Converter
- Model Quantization Tool
- Batch Inference Support
- Multi-GPU Support
- Metal Shader Graph Viewer
- SwiftData Entity Inspector
- Data Grid Viewer
- SwiftData Query Builder
- Migration Assistant
- JSON/YAML Editor with Validation
- JSON Schema Generation
- Gist Sharing Support
- Project Export to ZIP
- Docker Backend Support
- REST/SSE/WebSocket Clients
- HTTP Traffic Recorder
- OAuth2 UI
- Secrets Vault Integration
- Cloud SDK Support (AWS/GCP/Azure)
- Terraform Snippet Generator
- Ansible Snippet Generator
- Kubernetes YAML Generator
- Shell Script Generator
- CI Pipeline Generator
- Cron Scheduler UI
- File-system Watchers
- Macro Recorder
- Command Palette
- Global Search
- Bulk Rename Tool
- Git History Viewer
- Spell-check in Comments
- Markdown Preview
- DocC Documentation Site
- Interactive Tutorials
- Onboarding Wizard
- Settings Import/Export
- Feedback Form
- Telemetry Opt-in
- Usage Analytics Dashboards
- Unit Test Generator
- UI Test Generator
- Fuzz Testing Harness
- Accessibility Audit Tool
- VoiceOver Testing
- Automated Snapshot Testing
- Pixel-perfect Alignment Guide
- Grid Overlay in UI Previews
- Code Style Profile Editor
- Keyboard Shortcut Customizer
- Multi-window Support
- Diff & Merge Tool
- Asset Exporter
- SVG to Asset Variants
- Audio Alerts
- HomePod Handoff Support
- Notification Center Integration
- Plugin Marketplace
- Remote Control API
- Shortcuts Integration
- SQLite Viewer
- Database Rollback
- Scratchpad
- Markup Code Copy (MD/HTML)
- Productivity Timer
- CI Calendar View
- TODO List Manager
- Roadmap Import/Export
- Build/Test Notifications
- Customizable Templates
- Integrated AI Chat Helper

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (iOS/iPadOS)
- [ ] Адаптация layout с NavigationStack, SplitView (iPad)
- [ ] Минималистичный watchOS Chat & History
- [ ] Catalyst проверка и фиксы

### Поток History (feature/chat-history)
- [x] SwiftData Conversation/Message модели
- [x] Сохранение новых чатов
- [x] HistoryView + MessageListView
- [ ] Поиск (`.filter`) + SearchField
- [ ] Экспорт JSON/Markdown
- [ ] Тесты сохранения/поиска

### Поток Automation (feature/automation)
- [x] N8nService (REST + webhook)
- [x] AutomationView GUI
- [ ] Авторизация (API key)
- [ ] Поддержка облачного n8n
- [ ] Отмена Task + индикатор прогресса
- [ ] Автотесты webhooks

### Поток Scaffold Plugin (feature/scaffold-plugin)
- [x] ScaffoldingService GUI
- [ ] SPM Command Plugin (`scaffold`) 
- [ ] Swift Macro вариант
- [ ] Интеграция в CI (swift scaffold test)

## Следующие шаги (24h)
1. Завершить FileImporter и iOS layout (CrossPlatform).
2. Добавить поиск в HistoryView и экспорт (History).
3. Реализовать авторизацию и отмену для Automation.
4. Скелет SPM CLI-плагина `aihelper-scaffold` и Swift Macro `@AutoCodable` готов – осталось интегрировать.
5. Настроить hot-reload (`swift run --watch`), IceCream кэш, snapshot-тесты, параллельный CI.
6. Интеграция MLX/gguf локального LLM (переход на llama.swift-mlx ветку).

### Accelerated Timeline
| Дата | Бета | Содержание |
|------|------|------------|
| 14 июн | 14 | SPM Plugin + Macros |
| 15 июн | 15 | Hot-reload & Build Cache |
| 16 июн | 16 | Snapshot Tests + Parallel CI |
| 17 июн | 17 | MLX Local LLM Integration |

# Прогресс (обновляется ежедневно)

| Дата | Поток | Задача | Статус |
|------|-------|--------|--------|
| Day 1 | Persistence | UserDefaults & SettingsStore | ✅ Завершено |
| Day 2 | Import | Drag&Drop JSON/YAML | ✅ Завершено |
| Day 2 | LLM Runner | Интеграция llama.swift | ✅ Завершено |
| Day 3 | LLM UI | UI выбора моделей | ✅ Завершено |
| Day 3 | Auto Mode | Локал/облако + Streaming | ✅ Завершено |
| Day 4 | Cloud LLM | OpenAI + n8n интеграция | ✅ Завершено |
| Day 4 | CodeGen Core | Отправка промптов + структура | ✅ Завершено |
| Day 5 | CodeGen UI | Прогресс/отмена | ✅ Завершено |
| Day 5 | Theme | SwiftUI6 Material + кастомизация | ✅ Завершено |
| Day 6 | Templates | JSON templates + SwiftData | ✅ Завершено |
| Day 7 | Scaffolding | GUI + сервис | ✅ Завершено |
| Day 7 | CrossPlatform | Пакет поддерживает iOS/watchOS | 🔄 В работе |
| Day 7 | History | Сохранение чатов + UI | 🔄 В работе |
| Day 7 | CI Matrix | Мультиплатформенные сборки | ⏳ Запланировано |
| Day 8 | Automation | n8n облако, отмена, тесты | ⏳ Запланировано |
| Day 8 | Scaffold Plugin | SPM Plugin / Macro | ⏳ Запланировано |

## Список задач по потокам

### Поток CrossPlatform (feature/ios-ui, feature/watch-ui)
- [x] Conditional App targets (macOS/iOS/watchOS)
- [ ] FileImporter вместо NSOpenPanel (