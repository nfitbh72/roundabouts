class_name RoadLanes
extends RefCounted
## How many lanes a road has, which way they run and where its OpenStreetMap
## line sits across them, read from its tags.
##
## "Forward" means the way the way was drawn, not the way traffic drives.

## Traffic runs in the direction the way was drawn.
const FORWARD_ONLY: int = 1
## Traffic runs against the direction the way was drawn.
const BACKWARD_ONLY: int = -1
const BOTH_WAYS: int = 0

## Lanes running the way the way was drawn.
var forward: int = 0
## Lanes running the other way.
var backward: int = 0
## Every lane, including any shared by both directions, such as a centre turning lane.
var total: int = 0
## [constant FORWARD_ONLY], [constant BACKWARD_ONLY] or [constant BOTH_WAYS].
var oneway: int = BOTH_WAYS
## The turn arrows of each forward lane from left to right, such as "left;through".
## Empty when not tagged. An untagged lane in a tagged road is "none".
var turns_forward: PackedStringArray = PackedStringArray()
## The turn arrows of each backward lane, from left to right as its traffic sees them.
var turns_backward: PackedStringArray = PackedStringArray()
## Where the way's line sits across the road, in lanes from the road's left
## edge when looking along the way. Usually the middle, unless a placement tag
## says otherwise.
var way_position: float = 0.0


## Reads the lanes of a road from its [param tags].
static func from_tags(tags: Dictionary[String, String]) -> RoadLanes:
	var lanes: RoadLanes = RoadLanes.new()
	lanes.oneway = _oneway(tags)
	if lanes.oneway == BOTH_WAYS:
		_read_two_way(lanes, tags)
	else:
		_read_one_way(lanes, tags)
	lanes.way_position = _way_position(tags, lanes.total)
	return lanes


static func _read_one_way(lanes: RoadLanes, tags: Dictionary[String, String]) -> void:
	var count: int = _count(tags, "lanes", "turn:lanes")
	lanes.total = count if count > 0 else RoadTypes.default_lanes(tags, true)
	var turns: PackedStringArray = _turns(tags, "turn:lanes")
	if lanes.oneway == FORWARD_ONLY:
		lanes.forward = lanes.total
		lanes.turns_forward = turns
	else:
		lanes.backward = lanes.total
		lanes.turns_backward = turns


static func _read_two_way(lanes: RoadLanes, tags: Dictionary[String, String]) -> void:
	var forward: int = _count(tags, "lanes:forward", "turn:lanes:forward")
	var backward: int = _count(tags, "lanes:backward", "turn:lanes:backward")
	var shared: int = maxi(_int_tag(tags, "lanes:both_ways"), 0)
	var total: int = _int_tag(tags, "lanes")
	if total <= 0:
		total = forward + backward + shared if forward > 0 and backward > 0 else 0
	if total <= 0:
		total = RoadTypes.default_lanes(tags, false)
	if forward < 0 and backward < 0:
		backward = floori((total - shared) / 2.0)
	if forward < 0:
		forward = maxi(total - backward - shared, 0)
	if backward < 0:
		backward = maxi(total - forward - shared, 0)
	lanes.forward = forward
	lanes.backward = backward
	lanes.total = maxi(total, forward + backward + shared)
	lanes.turns_forward = _turns(tags, "turn:lanes:forward")
	lanes.turns_backward = _turns(tags, "turn:lanes:backward")


static func _oneway(tags: Dictionary[String, String]) -> int:
	match tags.get("oneway", ""):
		"yes", "true", "1":
			return FORWARD_ONLY
		"-1", "reverse":
			return BACKWARD_ONLY
		"no", "false", "0":
			return BOTH_WAYS
	return FORWARD_ONLY if RoadTypes.is_implied_oneway(tags) else BOTH_WAYS


## Returns the lane count in [param lanes_key], or failing that the number of
## lanes listed in [param turns_key], or -1 if neither says.
static func _count(tags: Dictionary[String, String], lanes_key: String, turns_key: String) -> int:
	var count: int = _int_tag(tags, lanes_key)
	if count > 0:
		return count
	var turns: PackedStringArray = _turns(tags, turns_key)
	return turns.size() if not turns.is_empty() else -1


## Returns the whole number in tag [param key], or -1 if it is missing or not a
## single whole number, as in "2;3".
static func _int_tag(tags: Dictionary[String, String], key: String) -> int:
	var text: String = tags.get(key, "").strip_edges()
	return text.to_int() if text.is_valid_int() else -1


static func _turns(tags: Dictionary[String, String], key: String) -> PackedStringArray:
	if not tags.has(key):
		return PackedStringArray()
	var turns: PackedStringArray = PackedStringArray()
	for lane: String in tags[key].split("|"):
		var arrows: String = lane.strip_edges()
		turns.append(arrows if not arrows.is_empty() else "none")
	return turns


## Returns where the way's line runs, in lanes from the road's left edge,
## from its placement tags, or the middle of the road if it has none.
## A placement:backward tag counts lanes from the left as the backward traffic
## sees them, which is from the right edge as the way was drawn.
static func _way_position(tags: Dictionary[String, String], total: int) -> float:
	var forward: float = _lanes_from_left(tags.get("placement", tags.get("placement:forward", "")))
	if forward >= 0.0:
		return forward
	var backward: float = _lanes_from_left(tags.get("placement:backward", ""))
	if backward >= 0.0:
		return total - backward
	return total / 2.0


## Reads a placement value such as "right_of:1", which says the line runs along
## the right-hand side of lane 1, counting lanes from the left. Returns how many
## lanes in from the left the line runs, or -1 if the value cannot be read.
static func _lanes_from_left(placement: String) -> float:
	var parts: PackedStringArray = placement.split(":")
	if parts.size() != 2 or not parts[1].is_valid_int():
		return -1.0
	var lane: int = parts[1].to_int()
	match parts[0]:
		"left_of":
			return lane - 1.0
		"right_of":
			return float(lane)
		"middle_of":
			return lane - 0.5
	return -1.0
