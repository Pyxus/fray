extends "virtual_input.gd"

export var input_ids: PoolIntArray setget set_input_ids

var input_map: Dictionary
var is_components_pressed_on_release: bool

func is_pressed() -> bool:
	if input_map.empty():
		return false
		
	if not map_has_inputs():
		return false

	for input_id in input_ids:
		if not input_map[input_id].is_pressed():
			return false

	return true


func is_component(input_id: int) -> bool:
	return input_id in input_ids


func release_components() -> void:
	for input_id in input_ids:
		if input_map[input_id].is_pressed():
			input_map[input_id].previously_pressed = false


func set_input_ids(value: PoolIntArray) -> void:
	if value.size() < 2:
		push_warning("Combination must contain 2 or more inputs.")

	input_ids = value
	map_has_inputs()


func map_has_inputs() -> bool:
	if input_map.empty():
		return false

	for input in input_ids:
		if not input_map.has(input):
			push_error("Input with id %d does not exist in input map." % input)
			return false
	
	return true
