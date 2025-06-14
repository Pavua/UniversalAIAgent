NAME ?= FeatureName

.PHONY: launch build watch scaffold lint generate install-hooks scheduler

launch:
	@if command -v iceccd >/dev/null 2>&1; then \
		echo "⚡️ Starting IceCream daemon"; \
		iceccd --daemon & \
	else \
		echo "⚠️ iceccd not found, skipping IceCream daemon"; \
	fi; \
	if command -v entr >/dev/null 2>&1; then \
		echo "⚡️ Watching Swift files for changes"; \
		find Sources -type f -name '*.swift' | entr -c swift run AIHelperMacOS; \
	else \
		echo "⚠️ entr not found, running normally"; \
		swift run AIHelperMacOS; \
	fi

build:
	swift build

watch:
	@if command -v entr >/dev/null 2>&1; then \
		echo "⚡️ Watching Swift files for build"; \
		find Sources -type f -name '*.swift' | entr -c swift build; \
	else \
		echo "⚠️ entr not found, building normally"; \
		swift build; \
	fi

scaffold:
	swift package aihelper-scaffold $(NAME)

lint:
	swiftlint autocorrect --format
	swiftformat .

generate:
	@if ! command -v tuist >/dev/null 2>&1; then \
		echo "⚠️ tuist CLI not found, please install it (brew install tuist)"; \
	fi; \
	 tuist generate

install-hooks:
	git config core.hooksPath scripts
	chmod +x scripts/pre-commit.sh

scheduler:
	@if command -v icecream-scheduler >/dev/null 2>&1; then \
		echo "⚡️ Starting IceCream scheduler"; \
		icecream-scheduler --daemon; \
	else \
		echo "⚠️ icecream-scheduler not found; brew install icecream"; \
	fi 