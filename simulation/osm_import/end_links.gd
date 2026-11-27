class_name EndLinks
extends RefCounted
## Bookkeeping for joining lines, or roads, end to end.
##
## Each item has two ends, numbered 2 × index for its start and 2 × index + 1
## for its end. A link pairs the ends of two different items that should join.


## Returns the item that [param end] belongs to.
static func item(end: int) -> int:
	return end >> 1


## Returns true if [param end] is the end of its item rather than its start.
static func is_end(end: int) -> bool:
	return end & 1 == 1


## Returns the other end of the same item as [param end].
static func other(end: int) -> int:
	return end ^ 1


## Returns, for every end of [param count] items, the end it is linked to, or -1.
## [param pairs] lists candidate links as Vector2i(end, end), best first; each
## end takes the first candidate it appears in whose other end is still free.
static func linked(count: int, pairs: Array[Vector2i]) -> PackedInt32Array:
	var partners: PackedInt32Array = PackedInt32Array()
	partners.resize(count * 2)
	partners.fill(-1)
	for pair: Vector2i in pairs:
		if item(pair.x) == item(pair.y) or partners[pair.x] >= 0 or partners[pair.y] >= 0:
			continue
		partners[pair.x] = pair.y
		partners[pair.y] = pair.x
	return partners


## Returns the order in which to join [param count] items linked by
## [param partners], as runs of ends: each run lists, item by item, the end
## each item is entered by. Runs with a free end come first, starting there;
## then closed loops. The last entry of a loop's run is -1, marking it closed.
static func runs(count: int, partners: PackedInt32Array) -> Array[PackedInt32Array]:
	var used: PackedByteArray = PackedByteArray()
	used.resize(count)
	var result: Array[PackedInt32Array] = []
	for index: int in count:
		if used[index] == 0 and partners[index * 2] < 0:
			result.append(_run(index * 2, partners, used))
		elif used[index] == 0 and partners[index * 2 + 1] < 0:
			result.append(_run(index * 2 + 1, partners, used))
	for index: int in count:
		if used[index] == 0:
			result.append(_run(index * 2, partners, used))
	return result


static func _run(entry: int, partners: PackedInt32Array, used: PackedByteArray) -> PackedInt32Array:
	var run: PackedInt32Array = PackedInt32Array()
	var next: int = entry
	while next >= 0 and used[item(next)] == 0:
		used[item(next)] = 1
		run.append(next)
		next = partners[other(next)]
	if next >= 0:
		run.append(-1)
	return run
