class_name FrayDeviceState
extends RefCounted
## Used by FrayInput to track device state

## Type: Dictionary<String, InputState>
var input_state_by_name: Dictionary

## Type: Dictionary<String, bool>
var bool_by_condition: Dictionary


func flag_inputs_use_in_composite(composite: String, inputs: PackedStringArray) -> void:
	for input in inputs:
		if input_state_by_name.has(input):
			input_state_by_name[input].composites_used_in[composite] = true


func unflag_inputs_use_in_composite(composite: String, inputs: PackedStringArray) -> void:
	for input in inputs:
		if input_state_by_name.has(input):
			input_state_by_name[input].composites_used_in.erase(composite)


func flag_inputs_as_distinct(inputs: PackedStringArray, ignore_in_comp_check: bool = false) -> void:
	for input in inputs:
		if input_state_by_name.has(input) and (ignore_in_comp_check or input_state_by_name[input].composites_used_in.is_empty()):
			input_state_by_name[input].is_distinct = true

func unflag_inputs_as_distinct(inputs: PackedStringArray) -> void:
	for input in inputs:
		if input_state_by_name.has(input):
			input_state_by_name[input].is_distinct = false


func is_all_indistinct(inputs: PackedStringArray) -> bool:
	for input in inputs:
		if input_state_by_name.has(input) and input_state_by_name[input].is_distinct:
			return false
	return true


func get_pressed_inputs() -> PackedStringArray:
	var pressed_inputs: PackedStringArray
	for input in input_state_by_name:
		if input_state_by_name[input].pressed:
			pressed_inputs.append(input)
	return pressed_inputs


func get_unpressed_inputs() -> PackedStringArray:
	var unpressed_inputs: PackedStringArray
	for input in input_state_by_name:
		if not input_state_by_name[input].pressed:
			unpressed_inputs.append(input)
	return unpressed_inputs


func get_all_inputs() -> PackedStringArray:
	return PackedStringArray(input_state_by_name.keys())


func get_input_state(input_name: String) -> FrayInputState:
	if input_state_by_name.has(input_name):
		return input_state_by_name[input_name]
	return register_input_state(input_name)


func register_input_state(input_name: String) -> FrayInputState:
	var input_state := FrayInputState.new(input_name)
	input_state_by_name[input_name] = input_state
	return input_state


func is_condition_true(condition: String) -> bool:
	if bool_by_condition.has(condition):
		return bool_by_condition[condition]
	return false


func set_condition(condition: String, value: bool) -> void:
	bool_by_condition[condition] = value


func clear_conditions() -> void:
	bool_by_condition.clear()
