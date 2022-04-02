extends "input_bind.gd"

export var input_ids: PoolIntArray setget set_input_ids

var is_input_pressed_func: FuncRef
var has_input_func: FuncRef

func is_pressed() -> bool:
	if not map_has_inputs():
		return false

	for input_id in input_ids:
		if not is_input_pressed_func.call_func(input_id):
			return false

	return true


func is_component(input_id: int) -> bool:
	return input_id in input_ids


func set_input_ids(value: PoolIntArray) -> void:
	if value.size() < 2:
		push_warning("Combination must contain 2 or more inputs.")

	input_ids = value
	map_has_inputs()


func map_has_inputs() -> bool:
	for input in input_ids:
		if not has_input_func.call_func(input):
			push_error("Input with id %d does not exist in input map." % input)
			return false
	
	return true
