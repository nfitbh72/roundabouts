class_name PixelComponents
extends RefCounted
## Groups the set pixels of a mask into separate connected shapes.

const NEIGHBOURS: Array[Vector2i] = [
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, -1),
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
	Vector2i(1, 1),
]


## Returns the pixel coordinates of each shape in [param mask]. Pixels touching
## at an edge or a corner belong to the same shape. Shapes come back in the
## order their first pixel is met, reading left to right and top to bottom.
static func find(mask: BitMap) -> Array[PackedVector2Array]:
	var size: Vector2i = mask.get_size()
	var unvisited: PackedByteArray = mask.convert_to_image().get_data()
	var shapes: Array[PackedVector2Array] = []
	for index: int in unvisited.size():
		if unvisited[index] != 0:
			shapes.append(_flood(unvisited, size, index))
	return shapes


## Collects every pixel connected to [param start], clearing each from [param unvisited].
static func _flood(unvisited: PackedByteArray, size: Vector2i, start: int) -> PackedVector2Array:
	var pixels: PackedVector2Array = PackedVector2Array()
	var pending: PackedInt32Array = PackedInt32Array([start])
	unvisited[start] = 0
	while not pending.is_empty():
		var index: int = pending[pending.size() - 1]
		pending.resize(pending.size() - 1)
		var pixel: Vector2i = _pixel_at(index, size.x)
		pixels.append(Vector2(pixel))
		for offset: Vector2i in NEIGHBOURS:
			var next: Vector2i = pixel + offset
			if next.x < 0 or next.y < 0 or next.x >= size.x or next.y >= size.y:
				continue
			var next_index: int = next.y * size.x + next.x
			if unvisited[next_index] != 0:
				unvisited[next_index] = 0
				pending.append(next_index)
	return pixels


@warning_ignore("integer_division")
static func _pixel_at(index: int, width: int) -> Vector2i:
	return Vector2i(index % width, index / width)
