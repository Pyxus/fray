extends Node
##
## A singleton used to detect inputs.
##
## @desc:
##		Before use inputs must first be added to the FrayInputMap

const FrayInputEvent = preload("events/fray_input_event.gd")
const FrayInputMap_ = preload("fray_input_map.gd")
const FrayInputEventCombination = preload("events/fray_input_event_combination.gd")
const FrayInputEventConditional = preload("events/fray_input_event_conditional.gd")
const InputBind = preload("input_data/input_bind.gd")
const ActionInputBind = preload("input_data/action_input_bind.gd")
const JoyAxisInputBind = preload("input_data/joy_axis_input_bind.gd")
const CombinationInput = preload("input_data/combination_input.gd")

const DEVICE_ALL = -1
const DEVICE_KBM_JOY1 = 0

signal input_detected(input_event)

## Type: Dictionary<int, Dictionary<String, InputState>>
var _device_bind_input_states: Dictionary

## Type: Dictionary<int, Dictionary<String, InputState>>
var _device_combination_inputs_states: Dictionary 

## Type: Dictionary<int, Dictionary<String, bool>>
var _filtered_inputs: Dictionary

## Type: Dictionary<int, Dictionary<String, bool>>
var _pressed_inputs: Dictionary

## Type: Dictionary<int, Dictionary<String, bool>>
var _conditions: Dictionary 

onready var _input_map: FrayInputMap_ = get_node("/root/FrayInputMap")


func _ready() -> void:
	Input.connect("joy_connection_changed", self, "_on_Input_joy_connection_changed")

	for device in Input.get_connected_joypads():
		_connect_device(device)
	
	_connect_device(DEVICE_KBM_JOY1)


func _physics_process(delta: float) -> void:
	var connected_devices := get_connected_devices()
	
	for device in connected_devices:
		for bind_id in _input_map.get_input_bind_names():
			var bind := _input_map.get_input_bind(bind_id)
			var input_state := _get_input_state(bind_id, device)
			
			if bind.is_pressed(device):
				if not input_state.pressed:
					input_state.press()
					_add_pressed_input(bind_id, device)
			elif input_state.pressed:
				input_state.unpress()
				_remove_pressed_input(bind_id, device)
				_unfilter_input(bind_id, device)
	
		for combination_id in _input_map.get_combination_input_names():
			var combination := _input_map.get_combination_input(combination_id)
			var input_state := _get_input_state(combination_id, device)
			
			if _is_combination_pressed(combination, device):
				if not input_state.pressed:
					input_state.press()
					_add_pressed_input(combination_id, device)
					_filter_inputs(combination.components, device)
			elif input_state.pressed:
				input_state.unpress()
				_remove_pressed_input(combination_id, device)
				_unfilter_input(combination_id, device)
				_release_combination_components(combination, device)
	
		for conditional_id in _input_map.get_conditional_input_names():
			var input_state := _get_input_state(conditional_id, device)
			if is_just_pressed(conditional_id, device):
				if not _is_filtered_input(input_state.input, device):
					_add_pressed_input(conditional_id, device)
					_filter_input(input_state.input, device)
			elif is_just_released(conditional_id, device):
				_remove_pressed_input(conditional_id, device)
				_unfilter_input(conditional_id, device)

		for pressed_input in _pressed_inputs[device]:
			var input_state := _get_input_state(pressed_input, device)
			if is_just_pressed(pressed_input, device):
				if not _is_filtered_input(pressed_input, device):
					_emit_input_event(input_state, pressed_input, device, false, true)
				else:
					_emit_input_event(input_state, pressed_input, device, false, false)
			else:
				_emit_input_event(input_state, pressed_input, device, true, false)

## Returns the input map used by the FrayInput singleton
## The FrayInputMap is used to register inputs to be detected
func get_input_map() -> FrayInputMap_:
	return _input_map

## Returns true if an input is being pressed.
func is_pressed(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	var input_state := _get_input_state(input, device)

	if input_state == null:
		push_error("Unrecognized input '%s'" % input)
		return false
	
	return input_state.pressed

## Returns true when a user starts pressing the input, 
## meaning it's true only on the frame the user pressed down the input.
func is_just_pressed(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	var input_state := _get_input_state(input, device)
	
	if input_state == null:
		if not _input_map.has_input(input):
			push_error("Unrecognized input '%s'" % input)
		if not get_connected_devices().has(device):
			push_error("Unrecognized device '%s'" % device)
		return false
	
	if Engine.is_in_physics_frame():
		return input_state.pressed and input_state.physics_frame == Engine.get_physics_frames()
	else:
		return input_state.pressed and input_state.idle_frame == Engine.get_idle_frames()

## Returns true if input was explicitly pressed
## meaning it is only true if the 'just_pressed' was not
## trigerred by a combination component release.
func is_just_pressed_explicit(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	var input_state := _get_input_state(input, device)
	
	if input_state == null:
		if not _input_map.has_input(input):
			push_error("Unrecognized input '%s'" % input)
		if not get_connected_devices().has(device):
			push_error("Unrecognized device '%s'" % device)
		return false
	
	return is_just_pressed(input, device) and input_state.explicit_press

## Returns true when the user stops pressing the input, 
## meaning it's true only on the frame that the user released the button.
func is_just_released(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	var input_state := _get_input_state(input, device)
	
	if input_state == null:
		if not _input_map.has_input(input):
			push_error("Unrecognized input '%s'" % input)
		if not get_connected_devices().has(device):
			push_error("Unrecognized device '%s'" % device)
		return false
	
	if Engine.is_in_physics_frame():
		return not input_state.pressed and input_state.physics_frame == Engine.get_physics_frames()
	else:
		return not input_state.pressed and input_state.idle_frame == Engine.get_idle_frames()

## Get axis input by specifiying two input ids, one negative and one positive.
func get_axis(negative_input: String, positive_input: String, device: int = DEVICE_KBM_JOY1) -> float:
	return get_strength(positive_input, device) - get_strength(negative_input, device)

## Returns a value between 0 and 1 representing the intensity of an input.
## If the input has no range of strngth a discrete value of 0 or 1 will be returned.
func get_strength(input: String, device: int = DEVICE_KBM_JOY1) -> float:
	var input_bind: InputBind = _input_map.get_input_bind(input)
	
	if input_bind is ActionInputBind:
		return Input.get_action_strength(input_bind.action)
	elif input_bind is JoyAxisInputBind:
		return Input.get_joy_axis(device, input_bind.axis)
	
	return float(is_pressed(input, device))

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
	_conditions[device][condition] = value

## Returns the value of a condition set with set_condition.
func is_condition_true(condition: String, device: int = DEVICE_KBM_JOY1) -> bool:
	if _conditions[device].has(condition):
		return _conditions[device][condition]
	return false

## Clears the condition dict
func clear_conditions(device: int = DEVICE_KBM_JOY1) -> void:
	_conditions[device].clear()


func _emit_input_event(state: InputState, input: String, device: int, is_echo: bool, is_filtered: bool = false) -> void:
	var input_event := FrayInputEvent.new()
	
	if _input_map.has_combination_input(input):
		input_event = FrayInputEventCombination.new()
		for component in _input_map.get_combination_input(input).components:
			input_event.components.append(component)
	elif _input_map.has_conditional_input(input):
		input_event = FrayInputEventConditional.new()
		input_event.true_input = _get_input_state(input, device).input
		
	input_event.device = device
	input_event.input = input
	input_event.time_pressed = state.time_pressed
	input_event.time_emitted = OS.get_ticks_msec()
	input_event.echo = is_echo
	input_event.pressed = state.pressed
	input_event.filtered = is_filtered
	input_event.explicit_press = state.explicit_press
	
	emit_signal("input_detected", input_event)
	
	
func _add_pressed_input(input: String, device: int) -> void:
	_pressed_inputs[device][input] = true


func _remove_pressed_input(input: String, device: int) -> void:
	_pressed_inputs[device].erase(input)


func _is_filtered_input(input: String, device: int) -> bool:
	return _filtered_inputs[device].has(input)
	
	
func _filter_input(input: String, device: int) -> void:
	_filtered_inputs[device][input] = true
	

func _filter_inputs(ids: PoolStringArray, device: int) -> void:
	for id in ids:
		_filter_input(id, device)


func _unfilter_input(input: String, device: int) -> void:
	_filtered_inputs[device].erase(input)
	
	
func _release_combination_components(combination: CombinationInput, device: int) -> void:
	if combination.press_held_components_on_release:
		for component in combination.components:
			if is_pressed(component):
				var ci_state := _get_input_state(component, device)
				ci_state.press(false)
				_unfilter_input(component, device)
				
				
func _is_combination_quick_enough(device: int, components: PoolStringArray, tolerance: float = 30) -> bool:
	var avg_difference := 0
	for i in len(components):
		if i > 0:
			var input1 := _get_input_state(components[i], device)
			var input2 := _get_input_state(components[i-1], device)
			avg_difference += abs(input1.time_pressed - input2.time_pressed)

	avg_difference /= float(components.size())
	return avg_difference <= tolerance
	

func _is_combination_in_order(device: int, components: PoolStringArray, tolerance: float = 30) -> bool:
	if components.size() <= 1:
		return false

	for i in range(1, components.size()):
		var input1 := _get_input_state(components[i], device)
		var input2 := _get_input_state(components[i-1], device)

		if input2.time_stamp - tolerance > input1.time_stamp:
			return false

	return true
	

func _is_combination_pressed(combination: CombinationInput, device: int) -> bool:
	match combination.mode:
		CombinationInput.Mode.SYNC:
			return _is_combination_quick_enough(device, combination.components)
		CombinationInput.Mode.ASYNC:
			for component in combination.components:
				if not is_pressed(component):
					return false
			return true
		CombinationInput.Mode.ORDERED:
			return _is_combination_quick_enough(device, combination.components)
		CombinationInput.Mode.GROUPED:
			for component in combination.components:
				if is_pressed(component):
					return true
			return false
		var mode:
			push_error("Failed to check combination input. Unknown combination mode '%d'" % mode)

	return false


func _get_input_state(input: String, device: int) -> InputState:
	if device == DEVICE_ALL:
		for d_id in Input.get_connected_joypads():
			var input_state := _get_input_state(input, d_id)
			if input_state != null and input_state.pressed:
				return input_state
	else:
		if _input_map.has_input_bind(input):
			if not _device_bind_input_states[device].has(input):
				var input_state := InputState.new(input)
				_device_bind_input_states[device][input] = input_state
				
			return _device_bind_input_states[device][input]
		elif _input_map.has_combination_input(input):
			if not _device_combination_inputs_states[device].has(input):
				var input_state := InputState.new(input)
				_device_combination_inputs_states[device][input] = input_state
				
			return _device_combination_inputs_states[device][input]
		elif _input_map.has_conditional_input(input):
			var conditional_input := _input_map.get_conditional_input(input)
			var input_by_condition := conditional_input.input_by_condition
			for condition in input_by_condition:
				if is_condition_true(condition, device):
					return _get_input_state(input_by_condition[condition], device)
					
			return _get_input_state(conditional_input.default_input, device)
	
	return null

	
func _connect_device(device: int) -> void:
	_device_bind_input_states[device] = {}
	_device_combination_inputs_states[device] = {}
	_filtered_inputs[device] = {}
	_pressed_inputs[device] = {}
	_conditions[device] = {}
	

func _disconnect_device(device: int) -> void:
	_device_bind_input_states.erase(device)
	_device_combination_inputs_states.erase(device)
	_filtered_inputs.erase(device)
	_pressed_inputs.erase(device)
	_conditions.erase(device)
	
	
func _on_Input_joy_connection_changed(device: int, connected: bool) -> void:
	if device != DEVICE_KBM_JOY1:
		if connected:
			_connect_device(device)
		else:
			_disconnect_device(device)

	
class InputState:
	extends Reference
	
	func _init(input_name: String) -> void:
		input = input_name
	
	var input: String
	var pressed: bool
	var explicit_press: bool
	var physics_frame: int
	var idle_frame: int
	var time_pressed: int
	
	
	func press(is_explicit_press: bool = true) -> void:
		pressed = true
		physics_frame = Engine.get_physics_frames()
		idle_frame = Engine.get_idle_frames()
		time_pressed = OS.get_ticks_msec()
		explicit_press = is_explicit_press
	
	
	func unpress() -> void:
		pressed = false
		physics_frame = Engine.get_physics_frames()
		idle_frame = Engine.get_idle_frames()
