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

echo "==> Loading project"
load_output="$(godot --headless --import 2>&1)"
if grep -qE "ERROR|WARNING" <<<"$load_output"; then
	echo "$load_output"
	echo "The project loaded with errors or warnings."
	exit 1
fi

echo "==> Running tests"
godot --headless -s addons/gut/gut_cmdln.gd -gconfig=res://tests/gutconfig.json

echo "==> All checks passed"
