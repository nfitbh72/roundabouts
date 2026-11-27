class_name MapConverter
extends RefCounted
## Turns a screenshot of a junction into the lines the game redraws it from.
##
## The screenshot is only read, never kept: the result holds lines and nothing else.
## See docs/map-conversion-decision.md.

## Larger screenshots are scaled down to this many pixels on their longest side,
## which keeps the conversion quick without losing lane markings.
const MAX_SIDE: int = 1280
## A row of specks this close to a chained lane line is the same line found twice.
const DUPLICATE_DISTANCE: float = 4.0


## Returns the road edges and lane lines found in [param image].
##
## Works lanes first: finds the painted lane lines, then builds each road
## outwards from them. See docs/map-detection-decision.md.
static func from_image(image: Image) -> MapOutline:
	var working: Image = working_copy(image)
	var surface: BitMap = PixelClassifier.mask(working, PixelClassifier.Kind.SURFACE)
	var marking: BitMap = PixelClassifier.mask(working, PixelClassifier.Kind.MARKING)
	var shapes: Array[PackedVector2Array] = PixelComponents.find(marking)
	var chained: Array[PackedVector2Array] = LaneChains.join(LaneMarks.find(shapes, surface))
	var lane_lines: Array[PackedVector2Array] = chained.duplicate()
	lane_lines.append_array(find_dotted_lines(working, shapes, surface, chained))
	var road_edges: Array[PackedVector2Array] = build_road_edges(lane_lines, working)
	return MapOutline.new(working.get_size(), road_edges, lane_lines)


## Returns lane lines made of dashes too faint to make marks, found as rows of
## specks among the paint [param shapes] of [param image]. Rows with different
## colours either side are kerbs, and rows repeating a [param chained] line are dropped.
static func find_dotted_lines(
	image: Image,
	shapes: Array[PackedVector2Array],
	surface: BitMap,
	chained: Array[PackedVector2Array],
) -> Array[PackedVector2Array]:
	var dotted: Array[PackedVector2Array] = []
	for line: PackedVector2Array in DottedLines.find(
		PaintSpecks.find(shapes, surface), image.get_size()
	):
		if LineSides.are_alike(line, image):
			dotted.append(line)
	return DottedLines.new_lines(dotted, chained, DUPLICATE_DISTANCE)


## Returns the edges of the roads that [param lines] run along, using
## [param image] to find where the tarmac ends. Lines at junctions are left
## out, so that no edges are built across the middle of a junction.
static func build_road_edges(
	lines: Array[PackedVector2Array], image: Image
) -> Array[PackedVector2Array]:
	var width: float = LaneGroups.lane_width(lines)
	var along_roads: Array[PackedVector2Array] = JunctionLines.away_from_junctions(lines, width)
	var edges: Array[PackedVector2Array] = []
	for group: Array[PackedVector2Array] in LaneGroups.group(along_roads, width):
		edges.append_array(LaneRoadEdges.edges_of(group, width, image))
	return edges


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
