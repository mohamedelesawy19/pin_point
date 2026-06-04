# ─────────────────────────────────────────────────────────────────
# Flutter Project – Common Commands
# Usage: make <target>
# ─────────────────────────────────────────────────────────────────

.PHONY: help get clean format format-check analyze test coverage lint ci

# Default target
help:
	@echo ""
	@echo "  Usage: make <target>"
	@echo ""
	@echo "  Dev"
	@echo "    get            flutter pub get"
	@echo "    format         auto-format all Dart files"
	@echo "    analyze        flutter analyze"
	@echo "    test           run tests (randomised order)"
	@echo "    coverage       run tests + generate HTML coverage report"
	@echo ""
	@echo "  CI"
	@echo "    lint           format-check + analyze"
	@echo "    ci             full CI pipeline (lint + test)"
	@echo ""
	@echo "  Misc"
	@echo "    clean          flutter clean"
	@echo ""

# ── Dependencies ──────────────────────────────────────────────────

get:
	flutter pub get

# ── Code Quality ──────────────────────────────────────────────────

format:
	dart format .

format-check:
	dart format --set-exit-if-changed .

analyze:
	flutter analyze --fatal-infos

lint: format-check analyze

# ── Tests ─────────────────────────────────────────────────────────

test:
	flutter test --test-randomize-ordering-seed random

coverage:
	flutter test --coverage --test-randomize-ordering-seed random
	genhtml coverage/lcov.info --output-directory coverage/html --quiet
	@echo "Coverage report generated:"
	@echo "coverage/html/index.html"

# ── Full CI pipeline (mirrors GitHub Actions) ─────────────────────

ci: lint test
	@echo ""
	@echo "All CI checks passed!"

# ── Misc ──────────────────────────────────────────────────────────

clean:
	flutter clean
