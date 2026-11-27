class_name ContactSheet
extends RefCounted
## Writes the page that shows every map import trial side by side, with what
## changed since the last run.

const STYLE: String = """
body { background: #1f2226; color: #e6e6e6; font: 15px/1.5 system-ui, sans-serif; margin: 2em; }
h1 { font-size: 1.5em; margin: 0 0 0.2em; }
p.key { color: #9aa0a6; margin: 0 0 1.5em; }
.edge { color: #f2402f; } .lane { color: #4d99ff; }
table { border-collapse: collapse; margin-bottom: 2em; }
th, td { padding: 0.3em 1em 0.3em 0; text-align: left; border-bottom: 1px solid #33373c; }
td.number { text-align: right; font-variant-numeric: tabular-nums; }
.up { color: #7bd88f; } .down { color: #f2a33a; } .failed { color: #f2402f; }
section { margin-bottom: 3em; }
h2 { font-size: 1.1em; margin: 0 0 0.5em; }
img { max-width: 100%; }
"""


## Returns the page for [param trials], noting changes from the [param previous]
## counts, which are keyed by screenshot name as made by [method counts_of].
static func html(trials: Array[MapTrial], previous: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	parts.append('<!DOCTYPE html><html lang="en-GB"><head><meta charset="utf-8">')
	parts.append("<title>Map import trials</title><style>%s</style></head><body>" % STYLE)
	parts.append("<h1>Map import trials</h1>")
	parts.append(
		(
			'<p class="key"><span class="edge">Red</span>: road edges. '
			+ '<span class="lane">Blue</span>: lane lines. '
			+ "Changes are since the last run. These pictures are made from "
			+ "screenshots: keep them on this machine.</p>"
		)
	)
	parts.append(summary_table(trials, previous))
	for trial: MapTrial in trials:
		if trial.was_read():
			parts.append(
				(
					'<section><h2>%s</h2><img src="%s" alt=""></section>'
					% [trial.name.xml_escape(), trial.picture.uri_encode()]
				)
			)
	parts.append("</body></html>")
	return "\n".join(parts)


## Returns the table listing each trial's counts and how long it took.
static func summary_table(trials: Array[MapTrial], previous: Dictionary) -> String:
	var rows: PackedStringArray = PackedStringArray()
	rows.append(
		(
			"<table><tr><th>Screenshot</th><th>Size</th><th>Lane lines</th>"
			+ "<th>Road edges</th><th>Time</th></tr>"
		)
	)
	for trial: MapTrial in trials:
		var name: String = trial.name.xml_escape()
		if not trial.was_read():
			rows.append(
				'<tr><td>%s</td><td colspan="4" class="failed">Could not read</td></tr>' % name
			)
			continue
		rows.append(trial_row(trial, previous.get(trial.name, {})))
	rows.append("</table>")
	return "\n".join(rows)


## Returns the table row for [param trial], comparing with the counts from
## the last run in [param before], which is empty if there was none.
static func trial_row(trial: MapTrial, before: Dictionary) -> String:
	var cells: PackedStringArray = [
		trial.name.xml_escape(),
		"%d × %d" % [trial.size.x, trial.size.y],
		count_cell(trial.lane_lines, before.get("lane_lines", -1)),
		count_cell(trial.road_edges, before.get("road_edges", -1)),
		"%d ms" % trial.milliseconds,
	]
	return (
		(
			'<tr><td>%s</td><td>%s</td><td class="number">%s</td>'
			+ '<td class="number">%s</td><td class="number">%s</td></tr>'
		)
		% Array(cells)
	)


## Returns a count, followed by how it changed if there was an earlier count.
## [param before] is -1 when there was none.
static func count_cell(now: int, before: int) -> String:
	if before < 0 or before == now:
		return str(now)
	var change: int = now - before
	var direction: String = "up" if change > 0 else "down"
	return '%d <span class="%s">(%+d)</span>' % [now, direction, change]


## Returns the counts of every trial that could be read, keyed by screenshot
## name, ready to save for the next run to compare against.
static func counts_of(trials: Array[MapTrial]) -> Dictionary:
	var counts: Dictionary = {}
	for trial: MapTrial in trials:
		if trial.was_read():
			counts[trial.name] = trial.counts()
	return counts
