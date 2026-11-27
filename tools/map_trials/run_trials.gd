extends SceneTree
## Runs map import on every screenshot in a folder and writes a page comparing
## the results. Started by tools/try_maps.sh, which explains its arguments.

const IMAGE_EXTENSIONS: PackedStringArray = ["png", "jpg", "jpeg", "webp"]
const PAGE_NAME: String = "index.html"
const COUNTS_NAME: String = "counts.json"


func _init() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	if arguments.size() != 2:
		printerr("Expected two arguments: the screenshot folder and the results folder.")
		quit(1)
		return
	quit(run(arguments[0], arguments[1]))


## Runs every trial and writes the results. Returns the exit code.
func run(screenshots: String, results: String) -> int:
	var names: PackedStringArray = screenshot_names(screenshots)
	if names.is_empty():
		printerr("No screenshots found in %s." % screenshots)
		return 1
	var trials: Array[MapTrial] = []
	for name: String in names:
		var trial: MapTrial = MapTrial.run(screenshots.path_join(name), results)
		print(describe(trial))
		trials.append(trial)
	var counts_path: String = results.path_join(COUNTS_NAME)
	var page: String = ContactSheet.html(trials, previous_counts(counts_path))
	_write(results.path_join(PAGE_NAME), page)
	_write(counts_path, JSON.stringify(ContactSheet.counts_of(trials), "\t"))
	return 0


## Returns the names of the screenshots in [param folder], in alphabetical order.
static func screenshot_names(folder: String) -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for file: String in DirAccess.get_files_at(folder):
		if file.get_extension().to_lower() in IMAGE_EXTENSIONS:
			names.append(file)
	names.sort()
	return names


## Returns the counts saved by the last run, or an empty dictionary if there are none.
static func previous_counts(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var saved: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return saved if saved is Dictionary else {}


## Returns a one-line account of [param trial] for the terminal.
static func describe(trial: MapTrial) -> String:
	if not trial.was_read():
		return "%s: could not read" % trial.name
	return (
		"%s: %d lane lines, %d road edges, %d ms"
		% [trial.name, trial.lane_lines, trial.road_edges, trial.milliseconds]
	)


static func _write(path: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
