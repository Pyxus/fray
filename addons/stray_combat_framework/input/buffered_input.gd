extends Reference

var id: int
var time_stamp: int
var time_held: float
var was_released: bool

func calc_time_between(buffered_input: Reference) -> float:
    return abs(time_stamp - buffered_input.time_stamp)