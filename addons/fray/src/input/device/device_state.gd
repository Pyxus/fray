class_name FrayDeviceState
extends RefCounted
## Used by FrayInput to track device state

# Type: Dictionary<StringName, InputState>
var _input_state_by_name: Dictionary

# Type: Dictionary<StringName, bool>
var _bool_by_condition: Dictionary


func flag_inputs_use_in_composite(composite: StringName, inputs: PackedStringArray) -> void:
	for input in inputs:
		if _input_state_by_name.has(input):
			_input_state_by_name[input].composites_used_in[composite] = true


func unflag_inputs_use_in_composite(composite: StringName, inputs: PackedStringArray) -> void:
	for input in inputs:
		if _input_state_by_name.has(input):
			_input_state_by_name[input].composites_used_in.erase(composite)


func flag_inputs_as_distinct(inputs: PackedStringArray, ignore_in_comp_check: bool = false) -> void:
	for input in inputs:
		if _input_state_by_name.has(input) and (ignore_in_comp_check or _input_state_by_name[input].composites_used_in.is_empty()):
			_input_state_by_name[input].is_distinct = true

func unflag_inputs_as_distinct(inputs: PackedStringArray) -> void:
	for input in inputs:
		if _input_state_by_name.has(input):
			_input_state_by_name[input].is_distinct = false


func is_all_indistinct(inputs: PackedStringArray) -> bool:
	for input in inputs:
		if _input_state_by_name.has(input) and _input_state_by_name[input].is_distinct:
			return false
	return true


func get_pressed_inputs() -> PackedStringArray:
	var pressed_inputs: PackedStringArray
	for input in _input_state_by_name:
		if _input_state_by_name[input].pressed:
			pressed_inputs.append(input)
	return pressed_inputs


func get_unpressed_inputs() -> PackedStringArray:
	var unpressed_inputs: PackedStringArray
	for input in _input_state_by_name:
		if not _input_state_by_name[input].pressed:
			unpressed_inputs.append(input)
	return unpressed_inputs


func get_all_inputs() -> PackedStringArray:
	return PackedStringArray(_input_state_by_name.keys())


func get_input_state(input_name: StringName) -> FrayInputState:
	if _input_state_by_name.has(input_name):
		return _input_state_by_name[input_name]
	return register_input_state(input_name)


func register_input_state(input_name: StringName) -> FrayInputState:
	var input_state := FrayInputState.new(input_name)
	_input_state_by_name[input_name] = input_state
	return input_state


func is_condition_true(condition: StringName) -> bool:
	if _bool_by_condition.has(condition):
		return _bool_by_condition[condition]
	return false


func set_condition(condition: StringName, value: bool) -> void:
	_bool_by_condition[condition] = value


func clear_conditions() -> void:
	_bool_by_condition.clear()
