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


## Returns the elapsed time at which the line after the current one begins.
static func start_of_next_line(elapsed: float, seconds_per_line: float) -> float:
	return (line_index_at(elapsed, seconds_per_line) + 1) * seconds_per_line
