class_name JunctionImage
extends RefCounted
## Paints simple pretend aerial photos for the map import tests.

const GRASS: Color = Color8(70, 120, 50)
const TARMAC: Color = Color8(90, 90, 95)
const PAINT: Color = Color8(240, 240, 240)
const YELLOW_PAINT: Color = Color8(230, 200, 40)


## Returns a grass-coloured image of [param size].
static func grass(size: Vector2i) -> Image:
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(GRASS)
	return image


## Returns a grass image crossed left to right by a road from [param top] to
## [param bottom], with a dashed white line along its middle.
static func horizontal_road(size: Vector2i, top: int, bottom: int) -> Image:
	var image: Image = grass(size)
	image.fill_rect(Rect2i(0, top, size.x, bottom - top), TARMAC)
	paint_dashes(image, (top + bottom) / 2.0, 12, 8)
	return image


## Paints a two-pixel-wide dashed line across [param image], centred on [param y].
static func paint_dashes(image: Image, y: float, dash: int, gap: int) -> void:
	for x: int in range(0, image.get_width(), dash + gap):
		image.fill_rect(Rect2i(x, floori(y) - 1, dash, 2), PAINT)
