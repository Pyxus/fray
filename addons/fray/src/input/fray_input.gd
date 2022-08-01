extends Node

signal input_detected(input_event)

const FrayInputList = preload("fray_input_list.gd")
const InputState = preload("input_data/state/input_state.gd")
const InputInterface = preload("input_data/state/input_interface.gd")
const InputBindAction = preload("input_data/binds/input_bind_action.gd")
const InputBindJoyAxis = preload("input_data/binds/input_bind_joy_axis.gd")
const FrayInputEvent = preload("fray_input_event.gd")

const DEVICE_ALL = -1
const DEVICE_KBM_JOY1 = 0

var _input_list := FrayInputList.new()

## Type: Dictionary<int, DeviceState>
var _device_state_by_id: Dictionary


onready var _input_interface := InputInterface.new(weakref(self))


func _ready() -> void:
	Input.connect("joy_connection_changed", self, "_on_Input_joy_connection_changed")

	for device in Input.get_connected_joypads():
		_connect_device(device)
	
	_connect_device(DEVICE_KBM_JOY1)


func _physics_process(_delta: float) -> void:
	for device in get_connected_devices():
		var device_state := _get_device_state(device)

		for bind_name in _input_list.get_bind_names():
			var bind := _input_list.get_bind(bind_name)
			var input_state := device_state.get_input_state(bind_name)

			if bind.is_pressed(device):
				if not input_state.pressed:
					input_state.press()
			elif input_state.pressed:
				input_state.unpress()
		
		for complex_input_name in _input_list.get_complex_input_names():
			var complex_input := _input_list.get_complex_input(complex_input_name)
			var input_state := device_state.get_input_state(complex_input_name)

			if complex_input.is_pressed(device, _input_interface):
				if not input_state.pressed:
					input_state.press()
					device_state.filter(complex_input.get_binds())
			elif input_state.pressed:
				input_state.unpress()
				device_state.unfilter(complex_input.get_binds())

				if complex_input.is_virtual:
					for bind in complex_input.get_binds():
						var bind_state := _get_input_state(bind, device)
						if bind_state.pressed:
							bind_state.press(true)
		
		for pressed_input in device_state.get_pressed_inputs():
			var input_state := _get_input_state(pressed_input, device)
			var input_event := FrayInputEvent.new()
			
			input_event.device = device
			input_event.input = pressed_input
			input_event.time_pressed = input_state.time_pressed
			input_event.physics_frame = input_state.physics_frame
			input_event.idle_frame = input_state.idle_frame
			input_event.time_held = OS.get_ticks_msec() - input_state.time_pressed
			input_event.pressed = input_state.pressed
			input_event.virtually_pressed = input_state.virtually_pressed
			input_event.filtered = not device_state.is_filtered(pressed_input)

			if is_just_pressed(pressed_input, device):
				input_event.echo = false
			else:
				input_event.echo = true
			
			emit_signal("input_detected", input_event)

## Returns true if an input is being pressed.
func is_pressed(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	var input_state := _get_input_state(input, device)
	return input_state.pressed if input_state != null else false

## Returns true when a user starts pressing the input, 
## meaning it's true only on the frame the user pressed down the input.
func is_just_pressed(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	var input_state := _get_input_state(input, device)

	if input_state == null:
		return false

	if Engine.is_in_physics_frame():
		return input_state.pressed and input_state.physics_frame == Engine.get_physics_frames()
	else:
		return input_state.pressed and input_state.idle_frame == Engine.get_idle_frames()

## Returns true if input was physically pressed
## meaning it is only true if the press
## was not trigerred by a virtually.
func is_just_pressed_real(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	var input_state := _get_input_state(input, device)

	if input_state == null:
		return false

	return is_just_pressed(input, device) and not input_state.virtually_pressed


## Returns true when the user stops pressing the input, 
## meaning it's true only on the frame that the user released the button.
func is_just_released(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	var input_state := _get_input_state(input, device)

	if input_state == null:
		return false

	if Engine.is_in_physics_frame():
		return not input_state.pressed and input_state.physics_frame == Engine.get_physics_frames()
	else:
		return not input_state.pressed and input_state.idle_frame == Engine.get_idle_frames()

## Returns a value between 0 and 1 representing the intensity of an input.
## If the input has no range of strngth a discrete value of 0 or 1 will be returned.
func get_strength(input: String, device: int = DEVICE_KBM_JOY1) -> float:
	var input_state := _get_input_state(input, device)
	if _input_list.has_bind(input):
		var bind := _input_list.get_bind(input)

		if bind is InputBindAction:
			return Input.get_action_strength(bind.action)
		elif bind is InputBindJoyAxis:
			return Input.get_joy_axis(device, bind.axis)

	return float(input_state.pressed)

## Get axis input by specifiying two input ids, one negative and one positive.
func get_axis(negative_input: String, positive_input: String, device: int = DEVICE_KBM_JOY1) -> float:
	return get_strength(positive_input, device) - get_strength(negative_input, device)


## Returns an array of all connected devices.
## This array always contains device 0 as this represents
## both the keyboard and mouse as well as the first joypad
func get_connected_devices() -> Array:
	var connected_joypads := Input.get_connected_joypads()
	
	if connected_joypads.empty():
		connected_joypads.append(DEVICE_KBM_JOY1)
		
	return connected_joypads

## Sets condition to given value. Used for checking conditional inputs.
func set_condition(condition: String, value: bool, device: int = DEVICE_KBM_JOY1) -> void:
	_get_device_state(device).set_condition(condition, value)

## Returns the value of a condition set with set_condition.
func is_condition_true(condition: String, device: int = DEVICE_KBM_JOY1) -> bool:
	return _get_device_state(device).is_condition_true(condition)

## Clears the condition dict
func clear_conditions(device: int = DEVICE_KBM_JOY1) -> void:
	_get_device_state(device).clear_conditions()


func _connect_device(device: int) -> void:
	var device_state := DeviceState.new()
	var all_input_names :=\
		(_input_list.get_bind_names() +
		_input_list.get_complex_input_names()) #I just learned this trick, we coding in GD Lisp boys  
		
	for input_name in all_input_names:
		device_state.register_input_state(input_name)
	
	_device_state_by_id[device] = device_state


func _disconnect_device(device: int) -> void:
	_device_state_by_id.erase(device)


func _get_device_state(device: int) -> DeviceState:
	if _device_state_by_id.has(device):
		return _device_state_by_id[device]
	return null


func _get_input_state(input: String, device: int) -> InputState:
	var device_state := _get_device_state(device)
	var err_msg := ""

	if device_state == null:
		err_msg += "Unrecognized device '%d'" % device
	
	if not _input_list.has_input(input):
		err_msg += "\nUnrecognized input '%s'" % input
	
	if not err_msg.empty():
		push_error("Failed to get input state.")
		push_error(err_msg)
		return null

	return device_state.get_input_state(input)


func _get_bind_state(input: String, device: int) -> InputState:
	if _input_list.has_bind(input):
		return _get_input_state(input, device)
	return null


func _on_Input_joy_connection_changed(device: int, connected: bool) -> void:
	if device != DEVICE_KBM_JOY1:
		if connected:
			_connect_device(device)
		else:
			_disconnect_device(device)


class DeviceState:
	extends Reference

	const InputState = preload("input_data/state/input_state.gd")

	## Type: Dictionary<string, InputState>
	var input_state_by_name: Dictionary

	## Type: Dictionary<String, bool>
	var bool_by_condition: Dictionary

	## Type: Dictionary<String, bool>
	## Hint: Pseudo-Hashset
	var filtered_inputs: Dictionary

	func filter(inputs: PoolStringArray) -> void:
		for input in inputs:
			filtered_inputs[input] = true

	func unfilter(inputs: PoolStringArray) -> void:
		for input in inputs:
			if filtered_inputs.has(input):
				filtered_inputs.erase(input)

	func is_filtered(input: String) -> bool:
		return filtered_inputs.has(input)


	func get_pressed_inputs() -> PoolStringArray:
		var pressed_inputs: PoolStringArray
		for input in input_state_by_name:
			if input_state_by_name[input].pressed:
				pressed_inputs.append(input)
		return pressed_inputs

	func get_input_state(input_name: String) -> InputState:
		if input_state_by_name.has(input_name):
			return input_state_by_name[input_name]
		return register_input_state(input_name)


	func register_input_state(input_name: String) -> InputState:
		var input_state := InputState.new(input_name)
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
