class_name MapOutlineView
extends Node2D
## Draws a converted junction, scaled to fit the screen: red lines along the
## road edges and blue lines between the lanes.

const ROAD_EDGE_COLOR: Color = Color(0.95, 0.25, 0.2)
const LANE_LINE_COLOR: Color = Color(0.3, 0.6, 1.0)
const FRAME_COLOR: Color = Color(1.0, 1.0, 1.0, 0.15)
const ROAD_EDGE_WIDTH: float = 3.0
const LANE_LINE_WIDTH: float = 2.0
const FRAME_WIDTH: float = 1.0
## Space left around the junction, in screen pixels.
const MARGIN: float = 64.0

var _outline: MapOutline = null


func _ready() -> void:
	get_viewport().size_changed.connect(queue_redraw)


## Shows [param outline] in place of whatever was shown before.
func show_outline(outline: MapOutline) -> void:
	_outline = outline
	queue_redraw()


func _draw() -> void:
	if _outline == null:
		return
	var fit: Transform2D = fit_transform(Vector2(_outline.size), get_viewport_rect().size, MARGIN)
	draw_rect(fit * Rect2(Vector2.ZERO, Vector2(_outline.size)), FRAME_COLOR, false, FRAME_WIDTH)
	for edge: PackedVector2Array in _outline.road_edges:
		draw_polyline(fit * edge, ROAD_EDGE_COLOR, ROAD_EDGE_WIDTH, true)
	for lane: PackedVector2Array in _outline.lane_lines:
		draw_polyline(fit * lane, LANE_LINE_COLOR, LANE_LINE_WIDTH, true)


## Returns the transform that scales an area of [param content] size to fit
## inside [param screen], centred, with at least [param margin] on every side.
static func fit_transform(content: Vector2, screen: Vector2, margin: float) -> Transform2D:
	var room: Vector2 = (screen - Vector2(margin, margin) * 2.0).max(Vector2.ONE)
	var scale_to_fit: float = minf(room.x / maxf(content.x, 1.0), room.y / maxf(content.y, 1.0))
	var offset: Vector2 = (screen - content * scale_to_fit) / 2.0
	return Transform2D(0.0, Vector2(scale_to_fit, scale_to_fit), 0.0, offset)
