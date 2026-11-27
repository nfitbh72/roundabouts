class_name Median
extends RefCounted
## The middle value of a list, which shrugs off the odd wild measurement.


## Returns the median of [param values], or [param fallback] if there are none.
static func of(values: Array[float], fallback: float = 0.0) -> float:
	if values.is_empty():
		return fallback
	var sorted: Array[float] = values.duplicate()
	sorted.sort()
	var middle: int = sorted.size() >> 1
	if sorted.size() % 2 == 1:
		return sorted[middle]
	return (sorted[middle - 1] + sorted[middle]) / 2.0
