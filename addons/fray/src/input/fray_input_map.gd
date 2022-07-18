extends Node
## Contains a mapping of ids and and input binds

const FrayInputData = preload("input_data/fray_input_data.gd")
const InputBind = preload("input_data/input_bind.gd")
const ActionInputBind = preload("input_data/action_input_bind.gd")
const JoystickButtonInputBind = preload("input_data/joystick_button_input_bind.gd")
const JoystickAxisInputBind = preload("input_data/joystick_axis_input_bind.gd")
const KeyboardInputBind = preload("input_data/keyboard_input_bind.gd")
const MouseButtonInputBind = preload("input_data/mouse_button_input_bind.gd")
const CombinationInput = preload("input_data/combination_input.gd")
const ConditionalInput = preload("input_data/conditional_input.gd")

## Type: Dictionary<String, InputBind>
var _input_bind_by_name: Dictionary

## Type: Dictionary<String, CombinationInput>
var _combination_input_by_name: Dictionary

## Type: Dictionary<String, ConditionalInput>
var _conditional_input_by_name: Dictionary

## Adds input to set with given name.
func add_input(name: String, input_bind: InputBind) -> void:
	if _err_input_already_exists(name, "Failed to add input bind. "):
		return
	_input_bind_by_name[name] = input_bind

## Adds action input
func add_action_input(name: String, action: String = "") -> void:
	var action_input := ActionInputBind.new()
	action_input.action = action
	add_input(name, action_input)

## Adds joystick button input
func add_joystick_button_input(name: String, button: int = -1) -> void:
	var joystick_input := JoystickButtonInputBind.new()
	joystick_input.button = button
	add_input(name, joystick_input)

## Adds joystick axis input
func add_joystick_axis_input(name: String, axis: int = -1, check_positive: bool = true, deadzone: float = 0.5) -> void:
	var joystick_axis_input := JoystickAxisInputBind.new()
	joystick_axis_input.axis = axis
	joystick_axis_input.deadzone = deadzone
	joystick_axis_input.check_positive = check_positive
	add_input(name, joystick_axis_input)

## Adds keyboard key input
func add_keyboard_input(name: String, key: int = -1) -> void:
	var keyboard_input := KeyboardInputBind.new()
	keyboard_input.key = key
	add_input(name, keyboard_input)

## Adds mouse button input
func add_mouse_button_input(name: String, button: int = -1) -> void:
	var mouse_input := MouseButtonInputBind.new()
	mouse_input.button = button
	add_input(name, mouse_input)

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
		push_error("Failed to add combination input. Combination name can not be included in components")
		return
	
	if components.size() <= 1:
		push_error("Failed to add combination input. Combination must contain 2 or more components.")
		return

	for cid in components:
		if not has_input_bind(cid):
			push_error("Failed to add combination input. Combined inputs contain unbound input '%d'" % cid)
			return
		
		if has_conditional_input(cid):
			push_error("Failed to add combination input. Combination components can not include a conditional input.")
			return

#		Disabled to support the experimental 'Group' feature of combination inputs
#		if _combination_input_by_name.has(cid):
#			push_error("Failed to add combination input. Combination components can not include a combination input.")
#			return

	var combination_input := CombinationInput.new()
	combination_input.components = components
	combination_input.type = type
	combination_input.press_held_components_on_release = press_held_components_on_release

	_combination_input_by_name[name] = combination_input

## Registers conditional input using input ids.
##
## The input_by_condition must be a string : int dictionary where the string represents the condition and the int is a valid input name.
## For example, {"is_on_left_side" : InputEnum.FORWARD, "is_on_right_side" : InputEnum.BACKWARD}
func add_conditional_input(name: String, default_input: String, input_by_condition: Dictionary) -> void:
	for cid in input_by_condition.values():
		if not _input_bind_by_name.has(cid) and not _combination_input_by_name.has(cid):
			push_error("Failed to add conditional input. Input dictionary contains unknown input '%s'" % cid)
			return
		
		if cid == name:
			push_error("Failed to add conditional input. Conditional input name can not be included in dictioanry.")
			return
	
	if not _input_bind_by_name.has(default_input) and not _combination_input_by_name.has(default_input):
		push_error("Failed to add conditional input. Default input '%s' does not exist" % default_input)
		return

	if default_input == name:
		push_error("Failed to add conditional input. Conditional input name can not be used as a default input.")
		return

	var conditional_input := ConditionalInput.new()
	conditional_input.default_input = default_input
	conditional_input.input_by_condition = input_by_condition
	_conditional_input_by_name[name] = conditional_input


## Remove input bind along with any combination input or conditional input using it as a component.
func remove_input_bind(input: String) -> void:
	if _input_bind_by_name.has(input):
		_input_bind_by_name.erase(input)
		_remove_dependent_inputs(input)


## Remove combination input along with any conditional input using it as a component.
func remove_combination_input(input: String) -> void:
	if _combination_input_by_name.has(input):
		_combination_input_by_name.erase(input)
		_remove_dependent_inputs(input)


## Remove conditional input.
func remove_conditional_input(input: String) -> void:
	if _conditional_input_by_name.has(input):
		_conditional_input_by_name.erase(input)


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
	for cid in _conditional_input_by_name:
		var conditional_input: ConditionalInput = _conditional_input_by_name[cid]
		if input == conditional_input.default_input or input in conditional_input.input_by_condition.values():
			remove_conditional_input(cid)
			
	for cid in _combination_input_by_name:
		var combination_input: CombinationInput = _combination_input_by_name[cid]
		if input in combination_input.components:
			remove_combination_input(cid)
