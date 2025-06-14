# AIHelper

Cross-platform SwiftUI app for AI-assisted development tasks (macOS, iOS, watchOS, Catalyst).

## Prerequisites
- Xcode 15 (Swift 5.10+)
- Homebrew
- Ruby & Bundler

## Install
1. Install CLI tools:
   ```sh
   brew install icecream entr swiftlint swiftformat tuist
   gem install bundler
   ```
2. Install dependencies:
   ```sh
   swift package resolve
   bundle install
   ```
3. Set up Git hooks and project:
   ```sh
   make install-hooks   # pre-commit: lint, format, build, test
   make generate        # Tuist generate Xcode workspace
   make scheduler       # start distributed IceCream scheduler
   ```

## Development
- `make launch` — live-reload with IceCream + entr
- `make build` — swift build
- `make watch` — watch Swift files for build

## Testing & Fastlane
- Run tests locally:
  ```sh
  swift test
  bundle exec fastlane tests
  ```
- Snapshot UI (iOS):
  ```sh
  bundle exec fastlane snapshot
  ```
- Beta (TestFlight):
  ```sh
  bundle exec fastlane beta
  ```

## CI
Configured GitHub Actions with parallel jobs:
- Lint & Format
- Build (macOS & Ubuntu, Debug & Release)
- Test + Fastlane tests

## Macros & Scaffolding
- Annotate models with `@AutoCodableMacro` to generate `CodingKeys`.
- Use `@AutoUIMacro` stub in `Sources/ScaffoldMacros/macros.swift` to scaffold SwiftUI forms.
- Run `swift package plugin run ScaffoldPlugin -- <ModuleName>` to generate view and ViewModel boilerplate.

Enjoy blazing-fast development! 🚀 