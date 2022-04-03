extends Reference

var time_stamp: int

func get_time_between(detected_input: Reference) -> float:
	return abs(time_stamp - detected_input.time_stamp)
