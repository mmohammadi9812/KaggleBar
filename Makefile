.PHONY: build test run package clean check cli

## Build all targets (debug)
build:
	swift build

## Run tests
test:
	swift test

## Build release, package app, and launch
run: package
	open KaggleBar.app

## Build release and create the .app bundle (does not open)
package:
	./Scripts/package_app.sh --no-open

## Remove build artifacts and app bundle
clean:
	swift package clean
	rm -rf KaggleBar.app KaggleBar.dmg

## Build, test, and optionally lint
check: build test
	@if command -v swiftformat >/dev/null 2>&1; then \
		echo "==> Running SwiftFormat check..."; \
		swiftformat --lint .; \
	else \
		echo "==> SwiftFormat not installed, skipping..."; \
	fi
	@if command -v swiftlint >/dev/null 2>&1; then \
		echo "==> Running SwiftLint check..."; \
		swiftlint; \
	else \
		echo "==> SwiftLint not installed, skipping..."; \
	fi

## Build and install the CLI to ~/.local/bin
cli: package
	chmod +x bin/install-kagglebar-cli.sh
	./bin/install-kagglebar-cli.sh
