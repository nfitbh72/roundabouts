class_name OverpassParser
extends RefCounted
## Reads the JSON that the Overpass API returns into roads, traffic signals
## and crossings.


## Returns what [param text] says about the roads, or null if it is not
## Overpass JSON. Ways that refer to nodes missing from the text keep the
## nodes that are there.
static func parse(text: String) -> OsmExtract:
	var json: JSON = JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return null
	var elements: Variant = (json.data as Dictionary).get("elements")
	if not elements is Array:
		return null
	var extract: OsmExtract = OsmExtract.new()
	var nodes: Dictionary[int, GeoPoint] = _read_nodes(elements, extract)
	for element: Dictionary in _elements_of_type(elements, "way"):
		var tags: Dictionary[String, String] = _tags(element)
		if tags.has("highway"):
			extract.roads.append(
				OsmRoad.new(int(element.get("id", 0)), tags, _points(element, nodes))
			)
	return extract


## Returns every node by its id, and adds those that are signals or crossings to [param extract].
static func _read_nodes(elements: Array, extract: OsmExtract) -> Dictionary[int, GeoPoint]:
	var nodes: Dictionary[int, GeoPoint] = {}
	for element: Dictionary in _elements_of_type(elements, "node"):
		var point: GeoPoint = GeoPoint.new(element.get("lat", 0.0), element.get("lon", 0.0))
		nodes[int(element.get("id", 0))] = point
		match _tags(element).get("highway", ""):
			"traffic_signals":
				extract.signals.append(point)
			"crossing":
				extract.crossings.append(point)
	return nodes


static func _elements_of_type(elements: Array, type: String) -> Array[Dictionary]:
	var matching: Array[Dictionary] = []
	for element: Variant in elements:
		if element is Dictionary and (element as Dictionary).get("type") == type:
			matching.append(element)
	return matching


static func _tags(element: Dictionary) -> Dictionary[String, String]:
	var tags: Dictionary[String, String] = {}
	var raw: Variant = element.get("tags")
	if raw is Dictionary:
		for key: Variant in raw:
			tags[str(key)] = str((raw as Dictionary)[key])
	return tags


static func _points(way: Dictionary, nodes: Dictionary[int, GeoPoint]) -> Array[GeoPoint]:
	var points: Array[GeoPoint] = []
	var ids: Variant = way.get("nodes")
	if ids is Array:
		for id: Variant in ids:
			if nodes.has(int(id)):
				points.append(nodes[int(id)])
	return points
