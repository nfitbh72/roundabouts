class_name WelcomeSequence
extends RefCounted
## Decides which line of the welcome text is on screen at a given moment.
##
## Pure functions only: the caller owns the clock and the text.


## Splits raw text into the lines to show, dropping blank lines and stray whitespace.
static func parse_lines(text: String) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	for raw_line: String in text.split("\n"):
		var line: String = raw_line.strip_edges()
		if not line.is_empty():
			lines.append(line)
	return lines


## Returns the index of the line showing after [param elapsed] seconds.
static func line_index_at(elapsed: float, seconds_per_line: float) -> int:
	return maxi(0, floori(elapsed / seconds_per_line))


## Returns true once every line has had its full time on screen.
static func is_finished(elapsed: float, line_count: int, seconds_per_line: float) -> bool:
	return line_index_at(elapsed, seconds_per_line) >= line_count


## Returns how visible the current line is, from 0.0 (hidden) to 1.0 (fully shown).
## Each line fades in over its first [param fade_seconds] and out over its last.
static func opacity_at(elapsed: float, seconds_per_line: float, fade_seconds: float) -> float:
	if elapsed < 0.0:
		return 0.0
	if fade_seconds <= 0.0:
		return 1.0
	var time_into_line: float = fposmod(elapsed, seconds_per_line)
	var fading_in: float = time_into_line / fade_seconds
	var fading_out: float = (seconds_per_line - time_into_line) / fade_seconds
	return clampf(minf(fading_in, fading_out), 0.0, 1.0)


## Returns the elapsed time at which the line after the current one begins.
static func start_of_next_line(elapsed: float, seconds_per_line: float) -> float:
	return (line_index_at(elapsed, seconds_per_line) + 1) * seconds_per_line
