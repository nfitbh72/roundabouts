class_name OsmExtract
extends RefCounted
## What OpenStreetMap knows about the roads around a place.

## Every way with a highway tag, footpaths included.
var roads: Array[OsmRoad] = []
## Nodes tagged highway=traffic_signals.
var signals: Array[GeoPoint] = []
## Nodes tagged highway=crossing: pedestrian crossings, signalled or not.
var crossings: Array[GeoPoint] = []
