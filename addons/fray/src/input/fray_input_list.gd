extends Node
## Contains a list of all inputs recognized by the FrayInput singleton

const InputBind = preload("input_data/binds/input_bind.gd")
const InputBindAction = preload("input_data/binds/input_bind_action.gd")
const InputBindJoyButton = preload("input_data/binds/input_bind_joy_button.gd")
const InputBindJoyAxis = preload("input_data/binds/input_bind_joy_axis.gd")
const InputBindKey = preload("input_data/binds/input_bind_key.gd")
const InputBindMouseButton = preload("input_data/binds/input_bind_mouse_button.gd")
const ComplexInput = preload("input_data/complex_input.gd")

## Type: Dictionary<String, InputBind>
var _input_bind_by_name: Dictionary

## Type: Dictionary<String, ComplexInput>
var _complex_input_by_name: Dictionary

func add_complex_input(name: String, complex_input: ComplexInput) -> void:
	if _err_input_already_exists(name, "Failed to add complex input."):
		return
	_complex_input_by_name[name] = complex_input

## Binds input to set with given name.
func add_bind_input(name: String, input_bind: InputBind) -> void:
	if _err_input_already_exists(name, "Failed to add input bind."):
		return
	_input_bind_by_name[name] = input_bind

## Binds action input
func add_bind_action(name: String, action: String) -> void:
	var bind := InputBindAction.new()
	bind.action = action
	
	if not InputMap.has_action(action):
		push_warning("Action '%s' does not exist." % action)

	add_bind_input(name, bind)

## Binds joystick button input
func add_bind_joy_button(name: String, button: int) -> void:
	var bind := InputBindJoyButton.new()
	bind.button = button
	add_bind_input(name, bind)

## Binds joystick axis input
func add_bind_joy_axis(name: String, axis: int, check_positive: bool = true, deadzone: float = 0.5) -> void:
	var bind := InputBindJoyAxis.new()
	bind.axis = axis
	bind.deadzone = deadzone
	bind.check_positive = check_positive
	add_bind_input(name, bind)

## Binds key input
func add_bind_key(name: String, key: int) -> void:
	var bind := InputBindKey.new()
	bind.key = key
	add_bind_input(name, bind)

## Binds mouse button input
func add_bind_mouse_button(name: String, button: int) -> void:
	var bind := InputBindMouseButton.new()
	bind.button = button
	add_bind_input(name, bind)

## Returns true if the given bind exists in the list.
func has_bind(bind_name: String) -> bool:
	return _input_bind_by_name.has(bind_name)

## Returns an arry of all input bind names.
func get_bind_names() -> PoolStringArray:
	return PoolStringArray(_input_bind_by_name.keys())

## Retruns input bind with given name if it exists.
func get_bind(bind_name: String) -> InputBind:
	if has_bind(bind_name):
		return _input_bind_by_name[bind_name]
	return null

## Returns true if the given complex input exists in the list.
func has_complex_input(input_name: String) -> bool:
	return _complex_input_by_name.has(input_name)

## Returns an array of all complex input names.
func get_complex_input_names() -> PoolStringArray:
	return PoolStringArray(_complex_input_by_name.keys())

## Returns complex input with given name if it exists.
func get_complex_input(input_name: String) -> ComplexInput:
	if has_complex_input(input_name):
		return _complex_input_by_name[input_name]
	return null

## Returns true if the given input exists within the list
func has_input(input_name: String) -> bool:
	return has_complex_input(input_name) or has_bind(input_name)


func _err_input_already_exists(input: String, err_msg: String) -> bool:
	if has_bind(input):
		push_error(err_msg + " Input bind with name '%s' already exists." % input)
		return true
	elif has_complex_input(input):
		push_error(err_msg + " Complex input with name '%s' already exists." % input)
		return true
	
	return false