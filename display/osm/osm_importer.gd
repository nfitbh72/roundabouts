class_name OsmImporter
extends Node
## Fetches the roads around a point from the public Overpass API and turns
## them into a [MapOutline].
##
## The network request lives here in display, so nothing in the simulation
## ever waits on the internet. The public server is meant for light use by
## people, not for a released game: see docs/map-detection-decision.md.

signal imported(outline: MapOutline)
signal failed(reason: String)

const URL: String = "https://overpass-api.de/api/interpreter"
## Names the game and nothing about the player, as the Overpass usage policy asks.
const USER_AGENT: String = "RoundaboutsAreBetter/0.1 (prototype)"
## Half the width of the square of map fetched, in metres.
const RADIUS: float = 150.0
## The query may take 25 seconds once it starts, and a busy server queues it first.
const TIMEOUT_SECONDS: float = 60.0

const NO_CONNECTION: String = "OpenStreetMap could not be reached. Is the internet switched on?"
const TOO_SLOW: String = "OpenStreetMap is slow to answer today. Try again in a minute."
const BUSY: String = "OpenStreetMap's server is busy (error %d). Try again in a minute."
const NOT_UNDERSTOOD: String = "OpenStreetMap replied, but not in a way the game understood."
const NO_ROADS: String = "OpenStreetMap knows of no roads there. Possibly it is a field."

var _request: HTTPRequest = HTTPRequest.new()
var _centre: GeoPoint = null


func _ready() -> void:
	_request.timeout = TIMEOUT_SECONDS
	_request.request_completed.connect(_on_request_completed)
	add_child(_request)


## Starts fetching the roads around [param centre], abandoning any fetch
## already under way. Emits [signal imported] or [signal failed] when done.
func fetch(centre: GeoPoint) -> void:
	cancel()
	_centre = centre
	var headers: PackedStringArray = [
		"User-Agent: " + USER_AGENT, "Content-Type: application/x-www-form-urlencoded"
	]
	var body: String = "data=" + OverpassQuery.roads_around(centre, RADIUS).uri_encode()
	if _request.request(URL, headers, HTTPClient.METHOD_POST, body) != OK:
		failed.emit(NO_CONNECTION)


## Abandons any fetch under way, without emitting anything.
func cancel() -> void:
	_request.cancel_request()


func _on_request_completed(
	result: int, code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result == HTTPRequest.RESULT_TIMEOUT:
		failed.emit(TOO_SLOW)
		return
	if result != HTTPRequest.RESULT_SUCCESS:
		failed.emit(NO_CONNECTION)
		return
	if code != HTTPClient.RESPONSE_OK:
		failed.emit(BUSY % code)
		return
	var extract: OsmExtract = OverpassParser.parse(body.get_string_from_utf8())
	if extract == null:
		failed.emit(NOT_UNDERSTOOD)
		return
	var outline: MapOutline = OsmOutline.build(extract, _centre, RADIUS)
	if outline.road_edges.is_empty() and outline.lane_lines.is_empty():
		failed.emit(NO_ROADS)
		return
	imported.emit(outline)
