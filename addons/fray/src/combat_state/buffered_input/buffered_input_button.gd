extends "buffered_input.gd"
## docstring

func _init(input_time_stamp: int = 0, input_id: int = -1, input_is_pressed: bool = true).(input_time_stamp) -> void:
	id = input_id
	is_pressed = input_is_pressed

var id: int
var is_pressed: bool
