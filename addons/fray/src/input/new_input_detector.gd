extends Node

const InputSet = preload("input_data/input_set.gd")
const InputBind = preload("input_data/binds/input_bind.gd")
const ActionInputBind = preload("input_data/binds/action_input_bind.gd")
const JoystickAxisInputBind = preload("input_data/binds/joystick_axis_input_bind.gd")
const CombinationInput = preload("input_data/combination_input.gd")

const DEVICE_ALL = -1
const DEVICE_KBM = 0

var _input_set: InputSet
var _released_input: PoolIntArray

## Type Dictionary<int, Dictionary<int, InputState>>
var _device_bind_input_states: Dictionary

## Type Dictionary<int, Dictionary<int, InputState>>
var _device_combination_inputs_states: Dictionary 

## Type Dictionary<int, Dictionary<int, bool>>
var _filtered_inputs: Dictionary

## Type Dictionary<int, Dictionary<int, bool>>
var _pressed_inputs: Dictionary

## Dictionary<String, bool>
var _conditions: Dictionary 


func _ready() -> void:
	Input.connect("joy_connection_changed", self, "_on_Input_joy_connection_changed")
	
	for device in Input.get_connected_joypads():
		_init_device_state(device)
	
	_init_device_state(DEVICE_KBM)


func _process(delta: float) -> void:
	var connected_devices := _get_all_devices()
	
	for bind_id in _input_set.get_input_bind_ids():
		var bind := _input_set.get_input_bind(bind_id)
		
		for device in connected_devices:
			var input_state := _get_input_state(bind_id, device)
			
			if bind.is_pressed(device):
				if not input_state.pressed:
					input_state.press()
					_add_pressed_input(bind_id, device)
			elif input_state.pressed:
				input_state.unpress()
				_remove_pressed_input(bind_id, device)
				_unfilter_input(bind_id, device)
	
	for combination_id in _input_set.get_combination_input_ids():
		var combination := _input_set.get_combination_input(combination_id)
		
		for device in connected_devices:
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
				
				if combination.press_held_components_on_release:
					for component in combination.components:
						if is_pressed(component):
							var ci_state := _get_input_state(component, device)
							ci_state.press()
							_unfilter_input(component, device)
	
	for conditional_id in _input_set.get_conditional_input_ids():
		for device in connected_devices:
			if is_just_pressed(conditional_id, device):
				var input_state := _get_input_state(conditional_id, device)
				if _filtered_inputs[device].has(input_state.id):
					continue
					
				_add_pressed_input(conditional_id, device)
				
				if false:
					var combination := _input_set.get_combination_input(input_state.id)
					if combination.press_held_components_on_release:
						_filter_input(input_state.id, device)
				else:
					_filter_input(input_state.id, device)
			elif is_just_released(conditional_id, device):
				_remove_pressed_input(conditional_id, device)
				_unfilter_input(conditional_id, device)
	
	for released_input in _released_input:
		# Feed to Sequence Analyzer
		pass
	
	for device in connected_devices:
		for pressed_input in _pressed_inputs[device]:
			if not _filtered_inputs[device].has(pressed_input):
				# Feed to Sequence Analyzer
				print(pressed_input)
				_filter_input(pressed_input, device)
		
	_released_input = []

## Returns true if an input is being pressed.
func is_pressed(id: int, device: int = DEVICE_KBM) -> bool:
	var input_state := _get_input_state(id, device)

	if input_state == null:
		push_error("Unrecognized input id '%d'" % id)
		return false
	
	return input_state.pressed

## Returns true when a user starts pressing the input, 
## meaning it's true only on the frame the user pressed down the input.
func is_just_pressed(id: int, device: int = DEVICE_KBM) -> bool:
	var input_state := _get_input_state(id, device)
	
	if input_state == null:
		push_error("Unrecognized input id '%d'" % id)
		return false
	
	if Engine.is_in_physics_frame():
		return input_state.pressed and input_state.physics_frame == Engine.get_physics_frames()
	else:
		return input_state.pressed and input_state.idle_frame == Engine.get_idle_frames()

## Returns true when the user stops pressing the input, 
## meaning it's true only on the frame that the user released the button.
func is_just_released(id: int, device: int = DEVICE_KBM) -> bool:
	var input_state := _get_input_state(id, device)
	
	if input_state == null:
		push_error("Unrecognized input id '%d'" % id)
		return false
	
	if Engine.is_in_physics_frame():
		return not input_state.pressed and input_state.physics_frame == Engine.get_physics_frames()
	else:
		return not input_state.pressed and input_state.idle_frame == Engine.get_idle_frames()

## Get axis input by specifiying two input ids, one negative and one positive.
func get_axis(negative_input_id: int, positive_input_id: int) -> float:
	return  get_strength(positive_input_id) - get_strength(negative_input_id)

## Returns a value between 0 and 1 representing the intensity of an input.
## If the input has no range of strngth a discrete value of 0 or 1 will be returned.
func get_strength(id: int) -> float:
	var input: InputBind = _input_set.get_input_bind(id)
	
	if input is ActionInputBind:
		return Input.get_action_strength(input.action)
	elif input is JoystickAxisInputBind:
		return Input.get_joy_axis(input.device, input.axis)
	
	return float(is_pressed(id))

## Sets condition to given value. Used for checking conditional inputs.
func set_condition(condition: String, value: bool) -> void:
	_conditions[condition] = value

## Returns the value of a condition set with set_condition.
func is_condition_true(condition: String) -> bool:
	if _conditions.has(condition):
		return _conditions[condition]
	return false

## Clears the condition dict
func clear_conditions() -> void:
	_conditions.clear()


func _add_pressed_input(id: int, device: int) -> void:
	_pressed_inputs[device][id] = true


func _remove_pressed_input(id: int, device: int) -> void:
	_pressed_inputs[device].erase(id)
	#_released_input.append(id)
	
	
func _filter_input(id: int, device: int) -> void:
	_filtered_inputs[device][id] = true
	

func _filter_inputs(ids: PoolIntArray, device: int) -> void:
	for id in ids:
		_filter_input(id, device)


func _unfilter_input(id: int, device: int) -> void:
	_filtered_inputs[device].erase(id)
	
	
func _get_all_devices() -> PoolIntArray:
	var connected_joypads := Input.get_connected_joypads()
	
	if connected_joypads.empty():
		connected_joypads.append(DEVICE_KBM)
		
	return PoolIntArray(connected_joypads)


func _is_combination_quick_enough(device: int, components: PoolIntArray, tolerance: float = 30) -> bool:
	var avg_difference := 0
	for i in len(components):
		if i > 0:
			var input1 := _get_input_state(components[i], device)
			var input2 := _get_input_state(components[i-1], device)
			avg_difference += abs(input1.time_pressed - input2.time_pressed)

	avg_difference /= float(components.size())
	return avg_difference <= tolerance
	

func _is_combination_in_order(device: int, components: PoolIntArray, tolerance: float = 30) -> bool:
	if components.size() <= 1:
		return false

	for i in range(1, components.size()):
		var input1 := _get_input_state(components[i], device)
		var input2 := _get_input_state(components[i-1], device)

		if input2.time_stamp - tolerance > input1.time_stamp:
			return false

	return true
	

func _is_combination_pressed(combination: CombinationInput, device: int) -> bool:
	match combination.type:
			CombinationInput.Type.SYNC:
				if not _is_combination_quick_enough(device, combination.components):
					return false
			CombinationInput.Type.ORDERED:
				if not _is_combination_quick_enough(device, combination.components):
					return false
	
	for component in combination.components:
		if not is_pressed(component):
			return false
			
	return true


func _get_input_state(id: int, device: int) -> InputState:
	if device == DEVICE_ALL:
		for d_id in Input.get_connected_joypads():
			var input_state := _get_input_state(id, d_id)
			if input_state != null and input_state.pressed:
				return input_state
	else:
		if _input_set.has_input_bind(id):
			if not _device_bind_input_states[device].has(id):
				var input_state := InputState.new(id)
				_device_bind_input_states[device][id] = input_state
				
			return _device_bind_input_states[device][id]
		elif _input_set.has_combination_input(id):
			if not _device_combination_inputs_states[device].has(id):
				var input_state := InputState.new(id)
				_device_combination_inputs_states[device][id] = input_state
				
			return _device_combination_inputs_states[device][id]
		elif _input_set.has_conditional_input(id):
			var conditional_input := _input_set.get_conditional_input(id)
			var input_by_condition := conditional_input.input_by_condition
			for condition in input_by_condition:
				if is_condition_true(condition):
					return _get_input_state(input_by_condition[condition], device)
					
			return _get_input_state(conditional_input.default_input, device)
	
	return null


func _init_device_state(device: int) -> void:
	_device_bind_input_states[device] = {}
	_device_combination_inputs_states[device] = {}
	_filtered_inputs[device] = {}
	_pressed_inputs[device] = {}
	

func _clear_device_state(device: int) -> void:
	_device_bind_input_states.erase(device)
	_device_combination_inputs_states.erase(device)
	_filtered_inputs.erase(device)
	_pressed_inputs.erase(device)
	
	
func _on_Input_joy_connection_changed(device: int, connected: bool) -> void:
	if device != DEVICE_KBM:
		if connected:
			_init_device_state(device)
		else:
			_clear_device_state(device)

	
class InputState:
	extends Reference
	
	func _init(input_id: int) -> void:
		id = input_id
	
	var id: int
	var pressed: bool
	var physics_frame: int
	var idle_frame: int
	var time_pressed: int
	var time_released: int
	
	
	func press() -> void:
		pressed = true
		physics_frame = Engine.get_physics_frames()
		idle_frame = Engine.get_idle_frames()
		time_pressed = OS.get_ticks_msec()
	
	
	func unpress() -> void:
		pressed = false
		physics_frame = Engine.get_physics_frames()
		idle_frame = Engine.get_idle_frames()
		time_released = OS.get_ticks_msec()


class DeviceInput:
	extends Reference
	
	var device: int
	var input: int 
