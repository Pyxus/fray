extends Node
## Contains a mapping of ids and and input binds

const FrayInputData = preload("input_data/fray_input_data.gd")
const InputBind = preload("input_data/input_bind.gd")
const ActionInputBind = preload("input_data/action_input_bind.gd")
const JoyButtonInputBind = preload("input_data/joy_button_input_bind.gd")
const JoyAxisInputBind = preload("input_data/joy_axis_input_bind.gd")
const KeyInputBind = preload("input_data/key_input_bind.gd")
const MouseButtonInputBind = preload("input_data/mouse_button_input_bind.gd")
const CombinationInput = preload("input_data/combination_input.gd")
const ConditionalInput = preload("input_data/conditional_input.gd")

## Type: Dictionary<String, InputBind>
var _input_bind_by_name: Dictionary

## Type: Dictionary<String, CombinationInput>
var _combination_input_by_name: Dictionary

## Type: Dictionary<String, ConditionalInput>
var _conditional_input_by_name: Dictionary

## Binds input to set with given name.
func bind_input(name: String, input_bind: InputBind) -> void:
	if _err_input_already_exists(name, "Failed to add input bind. "):
		return
	_input_bind_by_name[name] = input_bind

## Binds action input
func bind_action(name: String, action: String) -> void:
	var action_input := ActionInputBind.new()
	action_input.action = action
	
	if not InputMap.has_action(action):
		push_warning("Action '%s' does not exist." % action)

	bind_input(name, action_input)

## Binds joystick button input
func bind_joy_button(name: String, button: int) -> void:
	var joystick_input := JoyButtonInputBind.new()
	joystick_input.button = button
	bind_input(name, joystick_input)

## Binds joystick axis input
func bind_joy_axis(name: String, axis: int, check_positive: bool = true, deadzone: float = 0.5) -> void:
	var joystick_axis_input := JoyAxisInputBind.new()
	joystick_axis_input.axis = axis
	joystick_axis_input.deadzone = deadzone
	joystick_axis_input.check_positive = check_positive
	bind_input(name, joystick_axis_input)

## Binds key input
func bind_key(name: String, key: int) -> void:
	var keyboard_input := KeyInputBind.new()
	keyboard_input.key = key
	bind_input(name, keyboard_input)

## Binds mouse button input
func bind_mouse_button(name: String, button: int) -> void:
	var mouse_input := MouseButtonInputBind.new()
	mouse_input.button = button
	bind_input(name, mouse_input)

## Add combination input using other inputs as components.
##
## components is an array of input ids that compose the combination - the name assigned to a combination can not be used as a component
##
## If is_ordered is true, the combination will only be detected if the components are pressed in the order given.
## For example, if the components are 'forward' and 'button_a' then the combination is only triggered if 'forward' is pressed and held, then 'button_a' is pressed.
## The order is ignored if the inputs are pressed simeultaneously.
##
## if press_held_components_on_release is true, then when one component of a combination is released the remaining components are treated as if they were just pressed.
## This is useful for constructing the 'motion inputs' featured in many fighting games.
##
## if is_simeultaneous is true, the combination will only be detected if the components are pressed at the same time
func add_combination_input(
	name: String, 
	components: PoolStringArray, 
	press_held_components_on_release: bool = false, 
	type: int = CombinationInput.Type.SYNC
	) -> void:
	
	if _err_input_already_exists(name, "Failed to add combination input. "):
		return

	if name in components:
		push_error("Failed to add combination input. Combination can not include it self as component")
		return
	
	for input in components:
		if not has_input_bind(input):
			push_warning("Components contain unknown input '%s'." % input)
		elif has_conditional_input(input):
			push_error("Failed to add combination input. Combination components can not include a conditional input.")
			return

#		Disabled to support the experimental 'Group' feature of combination inputs
#		if _combination_input_by_name.has(input):
#			push_error("Failed to add combination input. Combination components can not include a combination input.")
#			return

	if components.size() <= 1:
		push_warning("Combination contains less than 2 or more components.")


	var combination_input := CombinationInput.new()
	combination_input.components = components
	combination_input.type = type
	combination_input.press_held_components_on_release = press_held_components_on_release

	_combination_input_by_name[name] = combination_input

## Registers conditional input using input ids.
##
## The input_by_condition must be a string : int dictionary where the string represents the condition and the int is a valid input name.
## For example, {"is_on_left_side" : InputEnum.FORWARD, "is_on_right_side" : InputEnum.BACKWARD}
func add_conditional_input(name: String, default_input: String = "", input_by_condition: Dictionary = {}) -> void:
	if _err_input_already_exists(name, "Failed to add conditional input. "):
		return

	if default_input == name:
		push_error("Failed to add conditional input. Conditional input can not use it self as default input.")
		return

	for input in input_by_condition.values():
		if not has_input(name):
			push_warning("Input dictionary contains unknown input '%s'" % input)
		elif input == name:
			push_error("Failed to add conditional input. Conditional input can not include it self in dictionary.")
			return

	if not has_input(default_input):
		push_warning("Default input '%s' does not exist." % default_input)

	var conditional_input := ConditionalInput.new()
	conditional_input.default_input = default_input
	conditional_input.input_by_condition = input_by_condition
	_conditional_input_by_name[name] = conditional_input

## Removes input with given name
func remove_input(input: String) -> void:
	if _input_bind_by_name.has(input):
		_input_bind_by_name.erase(input)
	elif _combination_input_by_name.has(input):
		_combination_input_by_name.erase(input)
	elif _combination_input_by_name.has(input):
		_combination_input_by_name.erase(input)
	else:
		push_warning("Input '%s' does not exist" % input)
		return
	
	_remove_dependent_inputs(input)


func get_input(input: String) -> FrayInputData:
	if has_input_bind(input):
		return get_input_bind(input)
	elif has_combination_input(input):
		return get_combination_input(input)
	elif has_conditional_input(input):
		return get_conditional_input(input)
	return null

## Returns input bind with given name
func get_input_bind(input: String) -> InputBind:
	if has_input_bind(input):
		return _input_bind_by_name[input]
	return null

## Returns combination input with given name
func get_combination_input(input: String) -> CombinationInput:
	if has_combination_input(input):
		return _combination_input_by_name[input]
	return null

## Returns conditional input with given name
func get_conditional_input(input: String) -> ConditionalInput:
	if has_conditional_input(input):
		return _conditional_input_by_name[input]
	return null

## Returns array of input bind ids
func get_input_bind_names() -> Array:
	return _input_bind_by_name.keys()

## Returns array of combination input ids
func get_combination_input_names() -> Array:
	return _combination_input_by_name.keys()

## Returns array of conditional input ids
func get_conditional_input_names() -> Array:
	return _conditional_input_by_name.keys()

## Returns true if the given name is mapped to some input
func has_input(name: String) -> bool:
	return has_input_bind(name)\
		or has_combination_input(name)\
		or has_combination_input(name)

## Returns true if the given name mapped to an input bind
func has_input_bind(name: String) -> bool:
	return _input_bind_by_name.has(name)

## Returns true if the given name is mapped to a combination input
func has_combination_input(name: String) -> bool:
	return _combination_input_by_name.has(name)

## Returns true if the given input is mapped to a conditional input
func has_conditional_input(name: String) -> bool:
	return _conditional_input_by_name.has(name)
	

func _err_input_already_exists(input: String, failed_to_add: String) -> bool:
	if has_input_bind(input):
		push_error("%sA input bind with name '%s' already exists" % [failed_to_add, input])
		return true
	elif has_combination_input(input):
		push_error("%sA combination input with name '%s' already exists" % [failed_to_add, input])
		return true
	elif has_conditional_input(input):
		push_error("%sA conditional input with name '%s' already exists" % [failed_to_add, input])
		return true
	return false


func _remove_dependent_inputs(input: String) -> void:
	for input in _conditional_input_by_name:
		var conditional_input: ConditionalInput = _conditional_input_by_name[input]
		if input == conditional_input.default_input or input in conditional_input.input_by_condition.values():
			remove_input(input)
			
	for input in _combination_input_by_name:
		var combination_input: CombinationInput = _combination_input_by_name[input]
		if input in combination_input.components:
			remove_input(input)
