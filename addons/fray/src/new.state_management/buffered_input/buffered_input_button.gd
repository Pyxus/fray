extends "buffered_input.gd"
## Represents a buffered input button
##
## @dsec:
## 		In this context 'button' simply means a non-sequence input

func _init(input_time_stamp: int = 0, input_name: String = "", input_is_pressed: bool = true).(input_time_stamp) -> void:
	input = input_name
	is_pressed = input_is_pressed

var input: String
var is_pressed: bool
