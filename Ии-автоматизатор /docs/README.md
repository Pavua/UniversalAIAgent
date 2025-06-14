# AIHelper Documentation

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/Pavua/UniversalAIAgent.git
   cd UniversalAIAgent
   ```
2. Build the project:
   ```bash
   swift build --configuration release
   ```
3. Run the macOS app:
   ```bash
   swift run AIHelperMacOS
   ```
4. Explore features in UI: Chat, History, CodeGen, Automation, Dashboard

## Architecture Overview

The project is organized into modular services and UI components:

- **LLMService**: local and FoundationModels inference loader
- **HistorySearchService**: full-text search with GRDB/FTS5
- **CodeGenerationService**: streaming code scaffolding via LLM
- **AutomationEngine**: pluggable workflows (n8nEngine, NativeEngine)
- **PerformanceMonitor**: real-time memory/CPU metrics
- **LLMMetricsService**: measurement of tokens and latency

UI layers use SwiftUI 6 and ChartsKit for rich visualization. Data persistence is handled by SwiftData (Core ML integration).

## Onboarding

- Branches follow `feature/*` naming. Each stream runs in parallel:
  - history-grdb-fts
  - automation-n8n-embedded
  - ui-polish
  - ci-matrix
  - codegen-auto-mode
  - llm-metrics
  - docs-onboarding
  - telemetry-integration

- Refer to `AIHelperMacOS/Roadmap.md` for detailed roadmap and tasks.

## Contributing

1. Create a new branch from `main` with clear feature name.
2. Implement changes, add tests and commentary.
3. Push branch and open a PR targeting `main`.
4. Run CI tests and ensure all checks pass.
5. Assign reviewers and merge once approved.
