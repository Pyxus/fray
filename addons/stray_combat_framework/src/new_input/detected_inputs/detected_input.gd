extends Reference

var time_stamp: int

func get_time_between(buffered_input: Reference) -> float:
	return abs(time_stamp - buffered_input.time_stamp) / 1000.0
