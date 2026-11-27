class_name TrialPicture
extends RefCounted
## Paints the result of a map import trial: the screenshot darkened with the
## detected lines drawn over it, and beside it the lines on their own as the
## game shows them.
##
## For checking detection on the developer's own machine only. These pictures
## contain screenshot pixels, so they must never be committed or shared.

## Gap between the two halves of the picture, in pixels.
const GAP: int = 16
## How the screenshot is toned down so the lines stand out against it.
const PHOTO_BRIGHTNESS: float = 0.45
const PHOTO_SATURATION: float = 0.4
## Line widths in pixels. The picture is at the conversion's own scale, which
## is smaller than the screen, so these are thinner than in the game.
const ROAD_EDGE_WIDTH: int = 2
const LANE_LINE_WIDTH: int = 2


## Returns the two-part picture of [param outline] found in [param photo], which
## must be the working copy the outline was found in.
static func paint(photo: Image, outline: MapOutline) -> Image:
	var size: Vector2i = photo.get_size()
	var picture: Image = Image.create_empty(size.x * 2 + GAP, size.y, false, Image.FORMAT_RGBA8)
	picture.fill(Color.BLACK)
	var toned: Image = photo.duplicate() as Image
	toned.convert(Image.FORMAT_RGBA8)
	toned.adjust_bcs(PHOTO_BRIGHTNESS, 1.0, PHOTO_SATURATION)
	picture.blit_rect(toned, Rect2i(Vector2i.ZERO, size), Vector2i.ZERO)
	var background: Color = ProjectSettings.get_setting(
		"rendering/environment/defaults/default_clear_color", Color.BLACK
	)
	picture.fill_rect(Rect2i(Vector2i(size.x + GAP, 0), size), background)
	for offset: Vector2i in [Vector2i.ZERO, Vector2i(size.x + GAP, 0)]:
		draw_lines(picture, outline, Vector2(offset))
	return picture


## Draws the lines of [param outline] onto [param picture], shifted by [param offset].
static func draw_lines(picture: Image, outline: MapOutline, offset: Vector2) -> void:
	var shift: Transform2D = Transform2D(0.0, offset)
	for edge: PackedVector2Array in outline.road_edges:
		draw_line(picture, shift * edge, MapOutlineView.ROAD_EDGE_COLOR, ROAD_EDGE_WIDTH)
	for lane: PackedVector2Array in outline.lane_lines:
		draw_line(picture, shift * lane, MapOutlineView.LANE_LINE_COLOR, LANE_LINE_WIDTH)


## Draws [param line] onto [param picture] in [param color], [param width] pixels wide.
## Parts of the line off the picture are skipped.
static func draw_line(picture: Image, line: PackedVector2Array, color: Color, width: int) -> void:
	var bounds: Rect2i = Rect2i(Vector2i.ZERO, picture.get_size())
	var brush: Vector2i = Vector2i(width, width)
	for point: Vector2 in Polyline.resampled(line, 0.5):
		var corner: Vector2i = Vector2i((point - Vector2(brush) / 2.0).round())
		picture.fill_rect(Rect2i(corner, brush).intersection(bounds), color)
