class_name JunctionImage
extends RefCounted
## Paints simple pretend aerial photos for the map import tests.

const GRASS: Color = Color8(70, 120, 50)
const TARMAC: Color = Color8(90, 90, 95)
const PAINT: Color = Color8(240, 240, 240)
const YELLOW_PAINT: Color = Color8(230, 200, 40)
const DASH: int = 12
const DASH_GAP: int = 8


## Returns a grass-coloured image of [param size].
static func grass(size: Vector2i) -> Image:
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(GRASS)
	return image


## Returns a grass image crossed left to right by a road whose top edge is at
## [param top], made of [param lane_count] lanes each [param lane_width] pixels
## wide, with dashed white lines between the lanes.
static func horizontal_road(size: Vector2i, top: int, lane_width: int, lane_count: int) -> Image:
	var image: Image = grass(size)
	image.fill_rect(Rect2i(0, top, size.x, lane_width * lane_count), TARMAC)
	for lane: int in range(1, lane_count):
		paint_dashes(image, top + lane * lane_width)
	return image


## Paints a two-pixel-wide dashed line across [param image], centred on [param y].
static func paint_dashes(image: Image, y: int) -> void:
	for x: int in range(0, image.get_width(), DASH + DASH_GAP):
		image.fill_rect(Rect2i(x, y - 1, DASH, 2), PAINT)


## Paints a row of two-pixel paint specks across [param image], centred on
## [param y] and [param spacing] pixels apart: a dashed line too faint to make marks.
static func paint_specks(image: Image, y: int, spacing: int) -> void:
	for x: int in range(spacing / 2, image.get_width(), spacing):
		image.fill_rect(Rect2i(x - 1, y - 1, 2, 2), PAINT)
