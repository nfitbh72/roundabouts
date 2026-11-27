class_name MapConverter
extends RefCounted
## Turns a screenshot of a junction into the lines the game redraws it from.
##
## The screenshot is only read, never kept: the result holds lines and nothing else.
## See docs/map-conversion-decision.md.

## Larger screenshots are scaled down to this many pixels on their longest side,
## which keeps the conversion quick without losing lane markings.
const MAX_SIDE: int = 1280


## Returns the road edges and lane lines found in [param image].
##
## Works lanes first: finds the painted lane lines, then builds each road
## outwards from them. See docs/map-detection-decision.md.
static func from_image(image: Image) -> MapOutline:
	var working: Image = working_copy(image)
	var surface: BitMap = PixelClassifier.mask(working, PixelClassifier.Kind.SURFACE)
	var marking: BitMap = PixelClassifier.mask(working, PixelClassifier.Kind.MARKING)
	var lane_lines: Array[PackedVector2Array] = LaneChains.join(LaneMarks.find(marking, surface))
	var road: BitMap = RoadMask.from_surface(surface)
	var width: float = LaneGroups.lane_width(lane_lines)
	var road_edges: Array[PackedVector2Array] = []
	for lines: Array[PackedVector2Array] in LaneGroups.group(lane_lines, width):
		road_edges.append_array(LaneRoadEdges.edges_of(lines, width, road))
	return MapOutline.new(working.get_size(), road_edges, lane_lines)


## Returns a copy of [param image] in 8-bit RGBA, scaled down if it is too large.
## The original is left untouched.
static func working_copy(image: Image) -> Image:
	var copy: Image = image.duplicate() as Image
	copy.convert(Image.FORMAT_RGBA8)
	var longest: int = maxi(copy.get_width(), copy.get_height())
	if longest > MAX_SIDE:
		var scale: float = float(MAX_SIDE) / longest
		var size: Vector2i = (Vector2(copy.get_size()) * scale).round()
		copy.resize(maxi(size.x, 1), maxi(size.y, 1), Image.INTERPOLATE_BILINEAR)
	return copy
