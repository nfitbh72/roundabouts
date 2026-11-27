class_name PaintSpecks
extends RefCounted
## Finds specks of paint too small to be marks on their own: what is left of
## faint, worn or distant dashes once a screenshot has been compressed.

## Largest a speck can be, in pixels. Anything bigger is a mark or a blob.
const MAX_PIXELS: int = 12
## How far from a speck to look for tarmac, in pixels, and in how many directions.
const TARMAC_DISTANCE: float = 4.0
const DIRECTIONS: int = 8
## How many of those directions must find tarmac. Specks on roofs, trees and
## cars are noise; lane paint sits on the road.
const MIN_TARMAC_DIRECTIONS: int = 6


## Returns the centre of each small paint shape in [param shapes] that has
## tarmac in [param surface] all around it.
static func find(shapes: Array[PackedVector2Array], surface: BitMap) -> PackedVector2Array:
	var specks: PackedVector2Array = PackedVector2Array()
	for shape: PackedVector2Array in shapes:
		if shape.size() > MAX_PIXELS:
			continue
		# Pixel coordinates name a pixel's corner; the speck's centre is half a pixel in.
		var centre: Vector2 = Polyline.centre(shape) + Vector2(0.5, 0.5)
		if is_on_tarmac(centre, surface):
			specks.append(centre)
	return specks


## Returns true if most of the places around [param point] are tarmac.
static func is_on_tarmac(point: Vector2, surface: BitMap) -> bool:
	var bounds: Rect2i = Rect2i(Vector2i.ZERO, surface.get_size())
	var found: int = 0
	for step: int in DIRECTIONS:
		var around: Vector2 = point + Vector2.from_angle(TAU * step / DIRECTIONS) * TARMAC_DISTANCE
		var pixel: Vector2i = Vector2i(around.floor())
		if bounds.has_point(pixel) and surface.get_bitv(pixel):
			found += 1
	return found >= MIN_TARMAC_DIRECTIONS
