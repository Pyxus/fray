extends Resource
## docstring

const InputBind = preload("binds/input_bind.gd")
const ActionInputBind = preload("binds/action_input_bind.gd")
const JoystickInputBind = preload("binds/joystick_input_bind.gd")
const JoystickAxisInputBind = preload("binds/joystick_input_bind.gd")
const KeyboardInputBind = preload("binds/keyboard_input_bind.gd")
const MouseInputBind = preload("binds/mouse_input_bind.gd")
const CombinationInput = preload("combination_input.gd")
const ConditionalInput = preload("conditional_input.gd")

var _input_bind_by_id: Dictionary # Dictionary<int, InputBind>
var _combination_input_by_id: Dictionary # Dictionary<int, CombinationInput>
var _conditional_input_by_id: Dictionary # Dictionary<int, ConditionalInput>

## Adds input to set with given id.
func add_input(id: int, input_bind: InputBind) -> void:
	_input_bind_by_id[id] = input_bind

## Adds action input
func add_action_input(id: int, action: String) -> void:
	var action_input := ActionInputBind.new()
	action_input.action = action
	add_input(id, action_input)

## Adds joystick button input
func add_joystick_input(id: int, device: int, button: int) -> void:
	var joystick_input := JoystickInputBind.new()
	joystick_input.device = device
	joystick_input.button = button
	add_input(id, joystick_input)

## Adds joystick axis input
func add_joystick_axis(id: int, device: int, axis: int, deadzone: float) -> void:
	var joystick_axis_input := JoystickAxisInputBind.new()
	joystick_axis_input.device = device
	joystick_axis_input.axis = axis
	joystick_axis_input.deadzone = deadzone
	add_input(id, joystick_axis_input)

## Adds keyboard key input
func add_keyboard_input(id: int, key: int) -> void:
	var keyboard_input := KeyboardInputBind.new()
	keyboard_input.key = key
	add_input(id, keyboard_input)

## Adds mouse button input
func add_mouse_input(id: int, button: int) -> void:
	var mouse_input := MouseInputBind.new()
	mouse_input.button = button
	add_input(id, mouse_input)

## Registers combination input using input ids as components.
##
## components is an array of input ids that compose the combination - the id assigned to a combination can not be used as a component
##
## If is_ordered is true, the combination will only be detected if the components are pressed in the order given.
## For example, if the components are 'forward' and 'button_a' then the combination is only triggered if 'forward' is pressed and held, then 'button_a' is pressed.
## The order is ignored if the inputs are pressed simeultaneously.
##
## if press_held_components_on_release is true, then when one component of a combination is released the remaining components are treated as if they were just pressed.
## This is useful for constructing the 'motion inputs' featured in many fighting games.
##
## if is_simeultaneous is true, the combination will only be detected if the components are pressed at the same time
func add_combination_input(id: int, components: PoolIntArray, 
	press_held_components_on_release: bool = false, 
	type: int = CombinationInput.Type.SYNC) -> void:
	if _input_bind_by_id.has(id) or _conditional_input_by_id.has(id):
		push_error("Failed to register combination input. Combination id is already used by bound or registered input")
		return

	if id in components:
		push_error("Failed to register combination input. Combination id can not be included in components")
		return
	
	if components.size() <= 1:
		push_error("Failed to register combination input. Combination must contain 2 or more components.")
		return

	if _conditional_input_by_id.has(id):
		push_error("Failed to register combination input. Combination components can not include conditional input")
		return

	for cid in components:
		if not _input_bind_by_id.has(cid):
			push_error("Failed to register combination input. Combined ids contain unbound input '%d'" % cid)
			return
		
		if _conditional_input_by_id.has(cid):
			push_error("Failed to register combination input. Combination components can not include a conditional input")
			return

	var combination_input := CombinationInput.new()
	combination_input.components = components
	combination_input.type = type
	combination_input.press_held_components_on_release = press_held_components_on_release

	_combination_input_by_id[id] = combination_input

## Registers conditional input using input ids.
##
## The input_by_condition must be a string : int dictionary where the string represents the condition and the int is a valid input id.
## For example, {"is_on_left_side" : InputEnum.FORWARD, "is_on_right_side" : InputEnum.BACKWARD}
func add_conditional_input(id: int, default_input: int, input_by_condition: Dictionary) -> void:
	for cid in input_by_condition.values():
		if not _input_bind_by_id.has(cid) and not _combination_input_by_id.has(cid):
			push_error("Failed to register conditional input. Input dictionary contains unregistered and unbound input '%d'" % cid)
			return
		
		if cid == id:
			push_error("Failed to register conditional input. Conditional input id can not be included in input dictioanry.")
			return
	
	if not _input_bind_by_id.has(default_input) and not _combination_input_by_id.has(default_input):
		push_error("Failed to register conditional input. Default input '%d' is not bound or a registered combination" % default_input)
		return

	if default_input == id:
		push_error("Failed to register conditional input. Conditional input id can not be used as a default input.")
		return

	var conditional_input := ConditionalInput.new()
	conditional_input.default_input = default_input
	conditional_input.input_by_condition = input_by_condition
	_conditional_input_by_id[id] = conditional_input


## Remove input bind along with any combination input or conditional input using it as a component.
func remove_input_bind(id: int) -> void:
	if _input_bind_by_id.has(id):
		_input_bind_by_id.erase(id)

		for cid in _combination_input_by_id:
			var combination_input: CombinationInput = _combination_input_by_id[cid]
			if id in combination_input.components:
				remove_combination_input(cid)
		
		for cid in _conditional_input_by_id:
			var conditional_input: ConditionalInput = _conditional_input_by_id[cid]
			if id == conditional_input.default_input or id in conditional_input.input_by_condition.values():
				remove_conditional_input(cid)


## Remove combination input along with any conditional input using it as a component.
func remove_combination_input(id: int) -> void:
	if _combination_input_by_id.has(id):
		_combination_input_by_id.erase(id)
		
		for cid in _conditional_input_by_id:
			var conditional_input: ConditionalInput = _conditional_input_by_id[cid]
			if id == conditional_input.default_input or id in conditional_input.input_by_condition.values():
				remove_conditional_input(cid)


## Remove conditional input.
func remove_conditional_input(id: int) -> void:
	if _conditional_input_by_id.has(id):
		_conditional_input_by_id.erase(id)

## Returns input associated with given id. Input will be of type: InputBind | CombinationInput | ConditionalInput
func get_input(id: int) -> Reference:
	if _input_bind_by_id.has(id):
		return _input_bind_by_id[id]
	elif _combination_input_by_id.has(id):
		return _combination_input_by_id[id]
	elif _conditional_input_by_id.has(id):
		return _conditional_input_by_id[id]
	else:
		return null

## Returns input bind with given id
func get_input_bind(id: int) -> InputBind:
	if _input_bind_by_id.has(id):
		return _input_bind_by_id[id]
	return null

## Returns combination input with given id
func get_combination_input(id: int) -> CombinationInput:
	if _combination_input_by_id.has(id):
		return _combination_input_by_id[id]
	return null

## Returns conditional input with given id
func get_conditional_input(id: int) -> ConditionalInput:
	if _conditional_input_by_id.has(id):
		return _conditional_input_by_id[id]
	return null

## Returns array of input bind ids
func get_input_bind_ids() -> Array:
	return _input_bind_by_id.keys()

## Returns array of combination input ids
func get_combination_input_ids() -> Array:
	return _combination_input_by_id.keys()

## Returns array of conditional input ids
func get_conditional_input_ids() -> Array:
	return _conditional_input_by_id.keys()


func has_input_bind(id: int) -> bool:
	return _input_bind_by_id.has(id)


func has_combination_input(id: int) -> bool:
	return _combination_input_by_id.has(id)


func has_conditional_input(id: int) -> bool:
	return _conditional_input_by_id.has(id)
#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

#public methods

#private methods

#signal methods

#inner classes
