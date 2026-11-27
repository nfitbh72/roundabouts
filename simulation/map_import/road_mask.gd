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
