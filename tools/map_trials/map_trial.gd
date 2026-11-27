class_name MapTrial
extends RefCounted
## The result of running map import on one test screenshot.

## File name of the screenshot, without its folder.
var name: String = ""
## Size the screenshot was converted at.
var size: Vector2i = Vector2i.ZERO
## How long the conversion took, in milliseconds.
var milliseconds: int = 0
var lane_lines: int = 0
var road_edges: int = 0
## File name of the picture painted for it, or empty if the screenshot could not be read.
var picture: String = ""


## Runs map import on the screenshot at [param path], saves its picture into
## [param results_folder], and returns how it went.
static func run(path: String, results_folder: String) -> MapTrial:
	var trial: MapTrial = MapTrial.new()
	trial.name = path.get_file()
	var image: Image = Image.load_from_file(path)
	if image == null or image.is_empty():
		return trial
	var started: int = Time.get_ticks_msec()
	var outline: MapOutline = MapConverter.from_image(image)
	trial.milliseconds = Time.get_ticks_msec() - started
	trial.size = outline.size
	trial.lane_lines = outline.lane_lines.size()
	trial.road_edges = outline.road_edges.size()
	trial.picture = picture_name(trial.name)
	var painted: Image = TrialPicture.paint(MapConverter.working_copy(image), outline)
	painted.save_png(results_folder.path_join(trial.picture))
	return trial


## Returns the file name of the picture for the screenshot called [param screenshot].
## The screenshot's own extension is kept, so photo.jpg and photo.png don't clash.
static func picture_name(screenshot: String) -> String:
	return screenshot.replace(".", "_") + ".png"


## Returns true if the screenshot could be read and converted.
func was_read() -> bool:
	return not picture.is_empty()


## Returns the counts worth comparing between runs, keyed by what they count.
func counts() -> Dictionary[String, int]:
	return {"lane_lines": lane_lines, "road_edges": road_edges}
