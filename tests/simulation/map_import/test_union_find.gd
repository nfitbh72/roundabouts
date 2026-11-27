extends GutTest


func _items() -> Array[PackedVector2Array]:
	var items: Array[PackedVector2Array] = []
	for index: int in 4:
		items.append(PackedVector2Array([Vector2(index, index)]))
	return items


func _separate() -> Array[int]:
	var groups: Array[int] = [0, 1, 2, 3]
	return groups


func test_every_item_starts_in_its_own_group() -> void:
	assert_eq(UnionFind.collect(_separate(), _items()).size(), 4)


func test_joined_items_share_a_root() -> void:
	var groups: Array[int] = _separate()

	groups[UnionFind.root(groups, 0)] = UnionFind.root(groups, 2)
	groups[UnionFind.root(groups, 2)] = UnionFind.root(groups, 3)

	assert_eq(UnionFind.root(groups, 0), UnionFind.root(groups, 3))
	assert_ne(UnionFind.root(groups, 0), UnionFind.root(groups, 1))


func test_collect_keeps_the_order_items_first_appear_in() -> void:
	var groups: Array[int] = _separate()
	groups[UnionFind.root(groups, 1)] = UnionFind.root(groups, 3)

	var collected: Array = UnionFind.collect(groups, _items())

	assert_eq(collected.size(), 3)
	_assert_holds(collected[0], [0])
	_assert_holds(collected[1], [1, 3])
	_assert_holds(collected[2], [2])


## Checks [param group] holds exactly the items at [param indices], in that order.
func _assert_holds(group: Array[PackedVector2Array], indices: Array[int]) -> void:
	assert_eq(group.size(), indices.size())
	for position: int in mini(group.size(), indices.size()):
		assert_eq(group[position], _items()[indices[position]])
