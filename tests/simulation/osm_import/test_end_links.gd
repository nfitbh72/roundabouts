extends GutTest


func test_ends_number_two_to_an_item() -> void:
	assert_eq([EndLinks.item(5), EndLinks.is_end(5), EndLinks.other(5)], [2, true, 4])


func test_each_end_takes_its_first_free_candidate() -> void:
	var pairs: Array[Vector2i] = [Vector2i(1, 2), Vector2i(1, 4), Vector2i(3, 4)]

	var partners: PackedInt32Array = EndLinks.linked(3, pairs)

	assert_eq(partners, PackedInt32Array([-1, 2, 1, 4, 3, -1]))


func test_an_item_never_links_to_itself() -> void:
	assert_eq(EndLinks.linked(1, [Vector2i(0, 1)]), PackedInt32Array([-1, -1]))


func test_a_run_starts_at_a_free_end_and_follows_the_links() -> void:
	# Item 0 runs into item 1's end, so item 1 is entered backwards.
	var partners: PackedInt32Array = EndLinks.linked(2, [Vector2i(1, 3)])

	assert_eq(EndLinks.runs(2, partners), [PackedInt32Array([0, 3])])


func test_a_run_may_start_from_an_item_entered_backwards() -> void:
	var partners: PackedInt32Array = EndLinks.linked(2, [Vector2i(0, 2)])

	assert_eq(EndLinks.runs(2, partners), [PackedInt32Array([1, 2])])


func test_unlinked_items_run_alone() -> void:
	assert_eq(EndLinks.runs(2, EndLinks.linked(2, [])).size(), 2)


func test_a_loop_is_marked_closed() -> void:
	var partners: PackedInt32Array = EndLinks.linked(2, [Vector2i(1, 2), Vector2i(3, 0)])

	assert_eq(EndLinks.runs(2, partners), [PackedInt32Array([0, 2, -1])])
