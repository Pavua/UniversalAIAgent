.PHONY: venv install deps test python-tests xcodegen build-macos run precommit package notarize ci all clean n8n dev test-all watch-test llm-containers llm-stop setup status llm-setup dev-stack dev-stop

# Установить и активировать виртуальное окружение
venv:
	python3 -m venv .venv

install:
	@source .venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt && pip install pytest-xdist || true && pip install -e .

deps: venv install

test: deps
	@source .venv/bin/activate && export PYTHONPATH="$(pwd)" && pytest -q -n auto userbot/tests

# Генерация Xcode проекта SwiftUI
xcodegen:
	@brew install xcodegen || true
	@cd userbot/gui && xcodegen generate

# Сборка macOS приложения
build-macos:
	@$(MAKE) xcodegen
	@cd userbot/gui && xcodebuild build \
      -project Tg_python_llm.xcodeproj \
      -scheme Tg_python_llm \
      -destination 'platform=macOS,arch=arm64' \
      -parallelizeTargets \
      -jobs $(shell sysctl -n hw.ncpu) \
      CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
      ENABLE_TESTABILITY=NO

# Открыть приложение
run: build-macos
	@echo "Запускаю macOS приложение..."
	@cd userbot/gui && open build/Debug/Tg_python_llm.app || \
	 xcodebuild build -project Tg_python_llm.xcodeproj -scheme Tg_python_llm -destination 'platform=macOS' && \
	 open build/Debug/Tg_python_llm.app

# Быстрая разработка - сборка и запуск в одной команде
dev: deps xcodegen
	@echo "Режим быстрой разработки..."
	@cd userbot/gui && xcodebuild build -project Tg_python_llm.xcodeproj -scheme Tg_python_llm -destination 'platform=macOS' -parallelizeTargets -jobs $(shell sysctl -n hw.ncpu) && open build/Debug/Tg_python_llm.app

# Полное тестирование всех компонентов
test-all: deps
	@echo "Запуск полного тестирования..."
	@./test_all.sh

# Автоматический запуск тестов при изменении файлов
watch-test:
	@echo "Автоматическое тестирование при изменениях..."
	@brew install fswatch || true
	@fswatch -o userbot/ | xargs -n1 -I{} make test

# Запуск нескольких LLM контейнеров для параллельной разработки
llm-containers:
	@echo "Запуск LLM контейнеров для разработки..."
	@docker-compose up -d llama32-main llama32-test llama32-exp redis
	@echo "LLM контейнеры запущены на портах 11434-11436"

# Настройка LLM моделей
llm-setup: llm-containers
	@echo "Настройка LLM моделей..."
	@chmod +x setup_llm.sh && ./setup_llm.sh

# Остановка LLM контейнеров
llm-stop:
	@docker-compose stop llama32-main llama32-test llama32-exp redis
	@echo "LLM контейнеры остановлены"

# Полный стек для разработки (n8n + LLM + мониторинг)
dev-stack:
	@echo "Запуск полного стека для разработки..."
	@docker-compose up -d
	@echo "Полный стек запущен:"
	@echo "- n8n: http://localhost:5678"
	@echo "- LLM Main: http://localhost:11434"
	@echo "- LLM Test: http://localhost:11435"
	@echo "- LLM Exp: http://localhost:11436"
	@echo "- Redis: localhost:6379"
	@echo "- Prometheus: http://localhost:9090"

# Остановка всего стека
dev-stop:
	@docker-compose down
	@echo "Весь стек остановлен"

# Быстрая установка и настройка для нового окружения
setup: venv install xcodegen swiftgen
	@echo "Настройка завершена! Используйте 'make dev' для разработки"

# Проверка статуса всех сервисов
status:
	@echo "=== Статус проекта ==="
	@echo "Python окружение:"
	@test -d .venv && echo "✅ Виртуальное окружение активно" || echo "❌ Нет виртуального окружения"
	@echo "Docker контейнеры:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(llama|n8n)" || echo "❌ Нет активных контейнеров"
	@echo "LM Studio:"
	@curl -s http://localhost:1234/v1/models > /dev/null && echo "✅ LM Studio доступен" || echo "❌ LM Studio недоступен"

# Pre-commit hooks
precommit:
	@pip install pre-commit || true
	@brew install swiftlint swiftformat || true
	@pre-commit run --all-files

# Упаковка DMG через Fastlane
package:
	@fastlane mac package

# Нотаризация DMG через Fastlane
notarize:
	@fastlane mac notarize_dmg

# Сборка приложения iOS (симулятор)
build-ios:
	@$(MAKE) xcodegen
	@cd userbot/gui && xcodebuild build \
      -project Tg_python_llm.xcodeproj \
      -scheme Tg_python_llm_iOS \
      -destination 'platform=iPhoneSimulator,OS=17.0,name=iPhone 15' \
      -parallelizeTargets \
      -jobs $(shell sysctl -n hw.ncpu) \
      -sdk iphonesimulator \
      CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
      ENABLE_TESTABILITY=NO | cat

# Сборка приложения watchOS (симулятор)
build-watch:
	@$(MAKE) xcodegen
	@cd userbot/gui && xcodebuild build \
      -project Tg_python_llm.xcodeproj \
      -scheme Tg_python_llmWatch \
      -destination 'platform=watchOS Simulator,name=Apple Watch Series 9' \
      -parallelizeTargets \
      -jobs $(shell sysctl -n hw.ncpu) \
      -sdk watchsimulator \
      CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
      ENABLE_TESTABILITY=NO | cat

# Обновляем CI цель
ci: deps test precommit build-macos build-ios build-watch package notarize

# Собрать всё
all: deps test precommit build-macos package swiftgen

# Очистить окружение
clean:
	@rm -rf .venv build Tg_python_llm.dmg 

# Запуск n8n в терминале и открытие UI
n8n:
	@docker-compose up n8n
	@echo "Открываю UI n8n в браузере..."
	@open http://localhost:5678 

# Генерация SwiftGen
swiftgen:
	@brew install swiftgen || true
	@mkdir -p userbot/gui/Generated
	@swiftgen config run --config .swiftgen.yml 