class_name RoadMask
extends RefCounted
## Turns scattered tarmac pixels into a clean road shape.

## Gaps narrower than about twice this are filled: lane markings, cars, manhole covers.
const FILL_RADIUS: int = 6
## Grey strips narrower than about twice this are removed: footpaths, roof edges, noise.
const SPECK_RADIUS: int = 5


## Returns a cleaned-up copy of [param surface] with small gaps filled and specks removed.
## The original mask is left untouched.
static func from_surface(surface: BitMap) -> BitMap:
	var road: BitMap = surface.duplicate() as BitMap
	var whole: Rect2i = Rect2i(Vector2i.ZERO, road.get_size())
	road.grow_mask(FILL_RADIUS, whole)
	road.grow_mask(-FILL_RADIUS, whole)
	road.grow_mask(-SPECK_RADIUS, whole)
	road.grow_mask(SPECK_RADIUS, whole)
	return road


## Returns the part of a mask of [param size] that the clean-up can be trusted in.
## Shrinking treats everything beyond the image as empty, so a thin band around
## the edge loses its road. Anything outside this area should be ignored.
static func reliable_area(size: Vector2i) -> Rect2i:
	var inset: Vector2i = Vector2i.ONE * (FILL_RADIUS + SPECK_RADIUS)
	return Rect2i(inset, (size - inset * 2).max(Vector2i.ZERO))


## Returns a copy of [param road] shrunk inwards by [param distance] pixels.
static func shrunk(road: BitMap, distance: int) -> BitMap:
	var inner: BitMap = road.duplicate() as BitMap
	inner.grow_mask(-distance, Rect2i(Vector2i.ZERO, inner.get_size()))
	return inner
