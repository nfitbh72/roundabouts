class_name PixelColours
extends RefCounted
## Reads colours from an image as vectors with channels from 0 to 255, so
## colours can be averaged and their differences measured as distances.

## Offsets of the pixels averaged by [method smoothed]: a pixel and its four
## neighbours, which evens out the speckle of tarmac without blurring edges much.
const CROSS: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)
]


## Returns the colour of [param pixel] in [param image].
static func at(image: Image, pixel: Vector2i) -> Vector3:
	var color: Color = image.get_pixelv(pixel)
	return Vector3(color.r8, color.g8, color.b8)


## Returns the average colour of [param pixel] and its neighbours, leaving out
## any that fall off [param image].
static func smoothed(image: Image, pixel: Vector2i) -> Vector3:
	var bounds: Rect2i = Rect2i(Vector2i.ZERO, image.get_size())
	var total: Vector3 = Vector3.ZERO
	var count: int = 0
	for offset: Vector2i in CROSS:
		if bounds.has_point(pixel + offset):
			total += at(image, pixel + offset)
			count += 1
	if count == 0:
		return Vector3.ZERO
	return total / count


## Returns the average of [method smoothed] at each of [param points] that lies
## on [param image], or [code]Vector3(-1, -1, -1)[/code] if none do.
static func average(image: Image, points: PackedVector2Array) -> Vector3:
	var bounds: Rect2i = Rect2i(Vector2i.ZERO, image.get_size())
	var total: Vector3 = Vector3.ZERO
	var count: int = 0
	for point: Vector2 in points:
		var pixel: Vector2i = Vector2i(point.floor())
		if bounds.has_point(pixel):
			total += smoothed(image, pixel)
			count += 1
	if count == 0:
		return -Vector3.ONE
	return total / count
