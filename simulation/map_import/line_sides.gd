class_name LineSides
extends RefCounted
## Compares the colour either side of a line. A lane line has the same tarmac
## on both sides; a kerb has road on one side and pavement on the other.

## How far either side of the line to look, in pixels.
const DISTANCES: Array[float] = [3.0, 4.5, 6.0]
## How many places along the line to look from.
const SAMPLES: int = 11
## Largest difference between the two sides' average colours, as a distance
## between colours with channels from 0 to 255, for the sides to match.
const MAX_DIFFERENCE: float = 15.0


## Returns true if the two sides of [param line] in [param image] are much the same colour.
static func are_alike(line: PackedVector2Array, image: Image) -> bool:
	return difference(line, image) <= MAX_DIFFERENCE


## Returns how different the average colours either side of [param line] are.
static func difference(line: PackedVector2Array, image: Image) -> float:
	return average_beside(line, image, 1.0).distance_to(average_beside(line, image, -1.0))


## Returns the average colour beside [param line] on the side given by the sign
## of [param side], with channels from 0 to 255. Places off the image do not count.
static func average_beside(line: PackedVector2Array, image: Image, side: float) -> Vector3:
	var across: Vector2 = Polyline.direction(line).orthogonal() * signf(side)
	var bounds: Rect2i = Rect2i(Vector2i.ZERO, image.get_size())
	var total: Vector3 = Vector3.ZERO
	var looked: int = 0
	for step: int in SAMPLES:
		var along: Vector2 = line[0].lerp(line[-1], float(step) / (SAMPLES - 1))
		for distance: float in DISTANCES:
			var pixel: Vector2i = Vector2i((along + across * distance).floor())
			if bounds.has_point(pixel):
				var color: Color = image.get_pixelv(pixel)
				total += Vector3(color.r8, color.g8, color.b8)
				looked += 1
	if looked == 0:
		return Vector3.ZERO
	return total / looked
