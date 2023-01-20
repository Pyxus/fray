class_name _FrayInputMap
extends Node
## Singleton used to register inputs recognized by [_FrayInput] singleton
##
## Inputs in fray are input binds, or composite inputs, mapped to a string name.
## These names can not be shared between binds and composite inputs.


# Type: Dictionary<StringName, InputBind>
var _input_bind_by_name: Dictionary

# Type: Dictionary<StringName, CompositeInput>
var _composite_input_by_name: Dictionary

var _composites_sorted_by_priority: Array[StringName]

## Adds a composite input to the input map with a given [kbd]name[/kbd].[br]
##
## [b]Note:[/b] Composite inputs and binds can not share names! [br][br]
##
## Each composite input has a static builder method which returns a builder object.
## The builder object can be used to construct composite inputs as demonstrated below.
## 
## [codeblock]
## FrayInputMap.add_composite_input("down_right", FrayCombinationInput.builder()
##	.add_component(FraySimpleInput.builder().bind("down"))
##	.add_component(FraySimpleInput.builder().bind("right"))
##	.build()
##	)
## [/codeblock]
func add_composite_input(name: StringName, composite_input: FrayCompositeInput) -> void:
	if _err_input_already_exists(name, "Failed to add composite input."):
		return
	_composite_input_by_name[name] = composite_input
	_composites_sorted_by_priority.append(name)
	_composites_sorted_by_priority.sort_custom(
		func(in1, in2) -> bool:
			return _composite_input_by_name[in1].priority > _composite_input_by_name[in2].priority
	)

## Adds bind to the input map with a given [kbd]name[/kbd].
##
## [b]Note:[/b] Composite inputs and binds can not share names! [br][br]
##
func add_bind_input(name: StringName, input_bind: FrayInputBind) -> void:
	if _err_input_already_exists(name, "Failed to add input bind."):
		return
	_input_bind_by_name[name] = input_bind

## Binds action input.
func add_bind_action(name: StringName, action: String) -> void:
	var bind := FrayInputBindAction.new()
	bind.action = action
	
	if not InputMap.has_action(action):
		push_warning("Action '%s' does not exist." % action)

	add_bind_input(name, bind)

## Binds a fray action
func add_bind_fray_action(name: StringName, simple_binds: Array[FrayInputBindSimple]) -> void:
	var bind := FrayInputBindFrayAction.new()
	for s_bind in simple_binds:
		bind.add_bind(s_bind)
	
	add_bind_input(name, bind)

## Binds joystick button input.
func add_bind_joy_button(name: StringName, button: int) -> void:
	var bind := FrayInputBindJoyButton.new()
	bind.button = button
	add_bind_input(name, bind)

## Binds joystick axis input.
func add_bind_joy_axis(name: StringName, axis: int, check_positive: bool = true, deadzone: float = 0.5) -> void:
	var bind := FrayInputBindJoyAxis.new()
	bind.axis = axis
	bind.deadzone = deadzone
	bind.check_positive = check_positive
	add_bind_input(name, bind)

## Binds key input.
func add_bind_key(name: StringName, key: int) -> void:
	var bind := FrayInputBindKey.new()
	bind.key = key
	add_bind_input(name, bind)

## Binds mouse button input.
func add_bind_mouse_button(name: StringName, button: int) -> void:
	var bind := FrayInputBindMouseButton.new()
	bind.button = button
	add_bind_input(name, bind)


## Removes input from list. Both binds and composite inputs can be removed this way
func remove_input(name: StringName) -> void:
	if _err_input_does_not_exist(name, "Failed to remove input."):
		return

	if has_bind(name):
		_input_bind_by_name.erase(name)
	else:
		_composite_input_by_name.erase(name)
		_composites_sorted_by_priority.erase(name)

## Returns true if the given bind exists in the list.
func has_bind(bind_name: StringName) -> bool:
	return _input_bind_by_name.has(bind_name)

## Returns an arry of all input bind names.
func get_bind_names() -> PackedStringArray:
	return PackedStringArray(_input_bind_by_name.keys())

## Retruns input bind with given name if it exists.
func get_bind(bind_name: StringName) -> FrayInputBind:
	if has_bind(bind_name):
		return _input_bind_by_name[bind_name]
	return null

## Returns true if the given composite input exists in the list.
func has_composite_input(input_name: StringName) -> bool:
	return _composite_input_by_name.has(input_name)

## Returns an array of all composite input names.
func get_composite_input_names() -> PackedStringArray:
	return PackedStringArray(_composites_sorted_by_priority)

## Returns composite input with given name if it exists.
func get_composite_input(input_name: StringName) -> FrayCompositeInput:
	if has_composite_input(input_name):
		return _composite_input_by_name[input_name]
	return null

## Returns true if the given input exists within the list.
func has_input(input_name: StringName) -> bool:
	return has_composite_input(input_name) or has_bind(input_name)


func _err_input_already_exists(input: StringName, err_msg: String) -> bool:
	if has_bind(input):
		push_error(err_msg + " Input bind with name '%s' already exists." % input)
		return true
	elif has_composite_input(input):
		push_error(err_msg + " Composite input with name '%s' already exists." % input)
		return true
	
	return false


func _err_input_does_not_exist(input: StringName, err_msg: String) -> bool:
	if not has_bind(input) and not has_composite_input(input):
		push_error(err_msg + " Input bind or composite input with name '%s' does not exist." % input)
		return true
	
	return false
