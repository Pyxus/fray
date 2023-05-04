class_name FrayDeviceState
extends RefCounted
## Used by [_FrayInput] to track device state

# Type: Dictionary<StringName, InputState>
var _input_state_by_name: Dictionary

# Type: Dictionary<StringName, bool>
var _bool_by_condition: Dictionary

var _is_valid := true

## Returns [code]true[/code] if the input state is still valid.
func is_valid() -> bool:
	return _is_valid

## Invalidates this input state resulting in it being removed from the [_FrayInput] singleton.
func invalidate() -> void:
	_is_valid = false

## Returns an array containing the names of every pressed input in this device state.
func get_pressed_inputs() -> PackedStringArray:
	var pressed_inputs: PackedStringArray
	for input in _input_state_by_name:
		if _input_state_by_name[input].pressed:
			pressed_inputs.append(input)
	return pressed_inputs

## Returns an array containing the names of every unpressed input in this device state.
func get_unpressed_inputs() -> PackedStringArray:
	var unpressed_inputs: PackedStringArray
	for input in _input_state_by_name:
		if not _input_state_by_name[input].pressed:
			unpressed_inputs.append(input)
	return unpressed_inputs

## Returns the names of all inputs tracked by this device.
func get_all_inputs() -> PackedStringArray:
	return PackedStringArray(_input_state_by_name.keys())

## Returns the input state of an input associated with a given [kbd]input_name[\kbd],
## if it exists.
func get_input_state(input_name: StringName) -> FrayInputState:
	if _input_state_by_name.has(input_name):
		return _input_state_by_name[input_name]
	return register_input_state(input_name)

## Creates a new input state for the given [kbd]input_name[\kbd].
func register_input_state(input_name: StringName) -> FrayInputState:
	var input_state := FrayInputState.new(input_name)
	_input_state_by_name[input_name] = input_state
	return input_state

## Returns the state of a [kbd]condition[/kbd] set with [method set_condition].
func is_condition_true(condition: StringName) -> bool:
	if _bool_by_condition.has(condition):
		return _bool_by_condition[condition]
	return false

## Sets [kbd]condition[/kbd] to given [kbd]value[/kbd].
func set_condition(condition: StringName, value: bool) -> void:
	_bool_by_condition[condition] = value

## Clears all conditions on this device state.
func clear_conditions() -> void:
	_bool_by_condition.clear()

## Flags all [kbd]inputs[/kbd] given as being used by given [kbd]composite[/kbd].
func flag_inputs_use_in_composite(composite: StringName, inputs: PackedStringArray) -> void:
	for input in inputs:
		if _input_state_by_name.has(input):
			_input_state_by_name[input].composites_used_in[composite] = true

## Unflags all [kbd]inputs[/kbd] given as being used by given [kbd]composite[/kbd].
func unflag_inputs_use_in_composite(composite: StringName, inputs: PackedStringArray) -> void:
	for input in inputs:
		if _input_state_by_name.has(input):
			_input_state_by_name[input].composites_used_in.erase(composite)

## Sets all [kbd]inputs[/kbd] as distinct.
func set_inputs_as_distinct(inputs: PackedStringArray, ignore_in_comp_check: bool = false) -> void:
	for input in inputs:
		if _input_state_by_name.has(input) and (ignore_in_comp_check or _input_state_by_name[input].composites_used_in.is_empty()):
			_input_state_by_name[input].is_distinct = true

## Unsets all [kbd]inputs[/kbd] as distinct.
func unset_inputs_as_distinct(inputs: PackedStringArray) -> void:
	for input in inputs:
		if _input_state_by_name.has(input):
			_input_state_by_name[input].is_distinct = false

## Returns [code]true[/code] if all [kbd]inputs[/kbd] are distinct.
func is_all_distinct(inputs: PackedStringArray) -> bool:
	for input in inputs:
		if _input_state_by_name.has(input) and _input_state_by_name[input].is_distinct:
			return true
	return false

