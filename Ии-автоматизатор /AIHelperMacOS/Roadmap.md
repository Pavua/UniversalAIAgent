# AIHelperMacOS — Roadmap (update: 2025-06-14)

> Документ отражает текущее состояние разработки, разбивку по потокам и ближайшие задачи.

## Текущие ветки / Потоки
| Поток | Ветка | Состояние | Ближайшие задачи |
|-------|-------|-----------|------------------|
| Chat History & Search | `feature/history-grdb-fts` | 🟢  ФТС-поиск работает, триггеры добавлены | 1. Jump-to-message  2. Highlight совпадений 3. Инкрементальный индекс |
| Automation Workflows (n8n) | `feature/automation-n8n-embedded` | 🟢  `AutomationEngine` + `N8nEngine` | 1. Упаковать CLI 2. Авто-старт + health-check 3. UI-консоль |
| UI Polish & Navigation | `feature/ui-polish` | 🟢  Sidebar skeleton | 1. NavigationSplitView 2. Material-темы 3. Локализация RU/EN/ES/UA |
| CI Matrix | `feature/ci-matrix` | 🟢  macOS build + matrix scaffold | 1. iOS/watchOS `xcodebuild` 2. Кэш SPM 3. Telegram нотификации |
| CodeGen Auto-Mode | `feature/codegen-auto-mode` | 🟢  File-watcher сервис | 1. Интеграция с CodeGenService 2. UI лог |
| LLM Metrics | `feature/llm-metrics` | 🟢  LLMMetricsService | 1. Dashboard график 2. История замеров |
| Docs & Onboarding | `feature/docs-onboarding` | 🟢  README Quick Start | 1. Mermaid диаграмма 2. DocC сайт |
| Telemetry | `feature/telemetry-integration` | 🟢  TelemetryService + Sentry | 1. toggle в Settings 2. capture ошибок |
| Prompt Assist | `feature/assist-prompt` | 🟢  AssistView + CursorService | 1. Speech-to-Text 2. Сохранение файлов |

## Завершено
- Восстановлена `Package.swift`, сборка проходит ✅
- Добавлен `AIHelperApp` (@main) ✅
- Интегрирован Performance Dashboard (Charts) ✅

## Следующие 48 часов (приоритет)
1. Завершить Jump-to-message и подсветку (History).
2. Упаковка и автозапуск n8n (Automation).
3. Sidebar + локализация (UI Polish).
4. iOS/watchOS шаги в CI + Telegram.
5. Speech-to-Text + запись файлов (Assist).

## Дневные спринты
- **Day 1**: History (50 %), Automation (50 %)
- **Day 2**: UI (40 %), CI (40 %), Assist (20 %)
- **Day 3**: LLM-Metrics, Docs, Telemetry fin.

---
_Этот файл обновляется ботом при каждом существенном изменении._ 