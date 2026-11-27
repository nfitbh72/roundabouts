#!/usr/bin/env bash
# Runs map import on every screenshot in a folder and writes a page showing
# what it found in each: the lines over the screenshot, and the lines on their
# own as the game draws them. Counts are compared with the last run, so a
# change that helps one junction but breaks another shows up.
#
# Usage: tools/try_maps.sh <screenshot folder> [results folder]
#
# Results go in <screenshot folder>/results unless another folder is given.
# They contain screenshot pixels, so they must stay outside this repository.

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
	echo "Usage: tools/try_maps.sh <screenshot folder> [results folder]" >&2
	exit 1
fi
if [[ ! -d "$1" ]]; then
	echo "Not a folder: $1" >&2
	exit 1
fi

repository="$(cd "$(dirname "$0")/.." && pwd)"
screenshots="$(cd "$1" && pwd)"
results="${2:-$screenshots/results}"

# No screenshot pixels may end up in the repository (docs/map-conversion-decision.md).
inside_repository() {
	[[ "$1/" == "$repository/"* ]]
}
if inside_repository "$screenshots"; then
	echo "Keep screenshots outside the repository: $screenshots" >&2
	exit 1
fi
created_results=false
if [[ ! -d "$results" ]]; then
	mkdir -p "$results"
	created_results=true
fi
results="$(cd "$results" && pwd)"
if inside_repository "$results"; then
	if [[ "$created_results" == true ]]; then
		rmdir "$results"
	fi
	echo "Keep results outside the repository: $results" >&2
	exit 1
fi

# Remove the last page first, so a run that fails part way can't pass for a finished one.
rm -f "$results/index.html"

godot --headless --path "$repository" -s res://tools/map_trials/run_trials.gd -- \
	"$screenshots" "$results" 2>&1 | grep -vE '^Godot Engine|^$' || true

if [[ ! -f "$results/index.html" ]]; then
	echo "The trials did not finish. See the messages above." >&2
	exit 1
fi
echo "Results: $results/index.html"
