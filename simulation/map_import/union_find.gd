class_name UnionFind
extends RefCounted
## Helpers for sorting items into groups by joining pairs of them.
##
## [code]groups[/code] holds one entry per item. Each starts out pointing to
## itself; joining two items points one group's root at the other's.


## Returns the item at the root of the group that [param item] belongs to.
static func root(groups: Array[int], item: int) -> int:
	while groups[item] != item:
		item = groups[item]
	return item


## Returns the items of each group as a typed array, in the order each group's
## first item appears in [param items].
static func collect(groups: Array[int], items: Array[PackedVector2Array]) -> Array:
	var by_root: Dictionary[int, Array] = {}
	for index: int in items.size():
		var group: int = root(groups, index)
		if not by_root.has(group):
			var members: Array[PackedVector2Array] = []
			by_root[group] = members
		by_root[group].append(items[index])
	return by_root.values()
