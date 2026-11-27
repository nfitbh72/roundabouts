#!/usr/bin/env bash
# Runs every check that must pass before a commit:
# formatting, linting, a headless project load, and the tests.
#
# Usage: tools/check.sh          check only
#        tools/check.sh --fix    reformat files first, then check

set -euo pipefail

cd "$(dirname "$0")/.."

# pipx installs gdformat and gdlint here, which may not be on the PATH.
export PATH="$HOME/.local/bin:$PATH"

# Our own GDScript files: everything tracked or new, except third-party addons.
scripts=()
while IFS= read -r file; do
	scripts+=("$file")
done < <(git ls-files --cached --others --exclude-standard -- '*.gd' ':!addons')

if [[ ${#scripts[@]} -gt 0 ]]; then
	if [[ "${1:-}" == "--fix" ]]; then
		echo "==> Formatting"
		gdformat "${scripts[@]}"
	fi

	echo "==> Checking format"
	gdformat --check "${scripts[@]}"

	echo "==> Linting"
	gdlint "${scripts[@]}"
fi

# Godot and GUT colour their output; strip that so the patterns below match.
strip_colours() {
	sed $'s/\x1b\\[[0-9;]*m//g'
}

# Engine errors and warnings, wherever they come from.
ENGINE_NOISE='^[[:space:]]*(ERROR|WARNING|SCRIPT ERROR|SCRIPT WARNING):'

# GUT summary lines that only appear when something is wrong but not failing:
# nodes a test left behind, and tests that never assert anything.
GUT_NOISE='^(Orphans|Risky/Pending)[[:space:]]+[1-9]'

echo "==> Loading project"
load_output="$(godot --headless --import 2>&1 | strip_colours)"
if grep -qE "$ENGINE_NOISE" <<<"$load_output"; then
	echo "$load_output"
	echo "FAILED: the project loaded with errors or warnings."
	exit 1
fi

echo "==> Running tests"
test_status=0
test_output="$(godot --headless -s addons/gut/gut_cmdln.gd -gconfig=res://tests/gutconfig.json 2>&1 | strip_colours)" || test_status=$?
echo "$test_output"
if [[ $test_status -ne 0 ]]; then
	echo "FAILED: one or more tests failed."
	exit 1
fi
if grep -qE "$ENGINE_NOISE|$GUT_NOISE" <<<"$test_output"; then
	echo "FAILED: the tests passed, but with warnings, orphans or risky tests:"
	grep -E "$ENGINE_NOISE|$GUT_NOISE" <<<"$test_output"
	exit 1
fi

echo "==> All checks passed"
