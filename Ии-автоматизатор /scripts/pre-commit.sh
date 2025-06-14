#!/bin/sh
# Lint, format, build, and test before commit

set -e

if command -v swiftlint >/dev/null 2>&1; then
  echo "🔍 SwiftLint autocorrect";
  swiftlint autocorrect --format --quiet; 
else
  echo "⚠️ swiftlint not found, skipping";
fi

if command -v swiftformat >/dev/null 2>&1; then
  echo "🎨 SwiftFormat";
  swiftformat . --quiet;
else
  echo "⚠️ swiftformat not found, skipping";
fi

echo "🛠️ swift build";
swift build --configuration debug;

echo "🧪 swift test";
swift test --configuration debug;

echo "✅ Pre-commit checks passed";