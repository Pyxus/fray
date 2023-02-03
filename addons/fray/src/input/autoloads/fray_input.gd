class_name _FrayInput
extends Node
## Fray input manager singleton
##
## Functionally similar to Godot's built in `Input` singleton.

## Emitted when a [kbd]input_event[/kbd] is detected.
signal input_detected(input_event: FrayInputEvent)

## Emitted when a [kbd]device[/kbd] has been connected or disconnected
signal device_connection_changed(device: int, is_connected: bool)

## Device id of the keyboard and mouse as well as the first controller connected.
const DEVICE_KBM_JOY1 = 0

# Type: Dictionary<int, DeviceState>
var _device_state_by_id: Dictionary

var _last_physics_frame: int

@onready var _input_map: FrayInputMap = get_node("../FrayInputMap")
@onready var _input_interface := FrayInputInterface.new(weakref(self))


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_Input_joy_connection_changed)

	for device in Input.get_connected_joypads():
		_connect_device(device)
	
	_connect_device(DEVICE_KBM_JOY1)


func _physics_process(_delta: float) -> void:
	for device in get_connected_devices():
		var device_state := _get_device_state(device)

		for bind_name in _input_map.get_bind_names():
			var bind := _input_map.get_bind(bind_name)
			var input_state := device_state.get_input_state(bind_name)

			input_state.strength = bind.get_strength(device)

			if bind.is_pressed(device):
				if not input_state.is_pressed:
					input_state.press()
			elif input_state.is_pressed:
				input_state.unpress()
		
		for composite_input_name in _input_map.get_composite_input_names():
			var composite_input := _input_map.get_composite_input(composite_input_name)
			var input_state := device_state.get_input_state(composite_input_name)
			
			if composite_input.is_pressed(device, _input_interface):
				if not input_state.is_pressed:
					var my_components := composite_input.decompose(device, _input_interface)
					input_state.press()
					device_state.flag_inputs_use_in_composite(composite_input_name, my_components)
					
					if device_state.is_all_indistinct(my_components):
						device_state.unflag_inputs_as_distinct([composite_input_name])
					else:
						device_state.unflag_inputs_as_distinct(my_components)
			elif input_state.is_pressed:
				var my_components := composite_input.decompose(device, _input_interface)
				input_state.unpress()
				device_state.unflag_inputs_use_in_composite(composite_input_name, my_components)
				device_state.flag_inputs_as_distinct([composite_input_name], true)
				device_state.flag_inputs_as_distinct(my_components)

				if composite_input.is_virtual:
					var held_components: PackedStringArray
					for bind in my_components:
						if is_pressed(bind, device):
							held_components.append(bind)
					
					_virtually_press(held_components, device)

		for input in device_state.get_all_inputs():
			if is_just_pressed(input, device) or is_just_released(input, device):
				var input_event := _create_input_event(input, device)
				input_event.is_echo = false
				input_detected.emit(input_event)
			elif is_pressed(input, device):
				var input_event := _create_input_event(input, device)
				var is_same_physics_frame := _last_physics_frame - input_event.physics_frame <= 2

				if not is_same_physics_frame:
					input_event.is_echo = true
					input_detected.emit(input_event)

	_last_physics_frame = Engine.get_physics_frames()

## Returns [code]true[/code] if the [kbd]input[/kbd] is being pressed.
func is_pressed(input: StringName, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_input_state(input, device):
		var input_state:
			return input_state.is_pressed
		null:
			return false

## Returns [code]true[/code] if any of the [kbd]inputs[/kbd] given are being pressed.
func is_any_pressed(inputs: PackedStringArray, device: int = DEVICE_KBM_JOY1) -> bool:
	for input in inputs:
		if is_pressed(input, device):
			return true
	return false

## Returns [code]true[/code] if any [kbd]n[/kbd] count of the [kbd]inputs[/kbd] given are being pressed.
func is_any_pressed_n(inputs: PackedStringArray, n: int = 1, device: int = DEVICE_KBM_JOY1) -> bool:
	var count := 0

	if n > inputs.size():
		push_warning("'n' should not be greater than the number of inputs")
	
	for input in inputs:
		if is_pressed(input, device):
			count += 1
	
	if count >= n:
		return true
	
	return false

## Returns [code]true[/code] if all [kbd]inputs[/kbd] given are being pressed.
func is_all_pressed(inputs: PackedStringArray, device: int = DEVICE_KBM_JOY1) -> bool:
	if inputs.is_empty():
		return false
	
	for input in inputs:
		if not is_pressed(input, device):
			return false
	
	return true
	
## Returns [code]true[/code] if any bind is being pressed.
func is_anything_pressed(device: int = DEVICE_KBM_JOY1) -> bool:
	for bind in _input_map.get_bind_names():
		if is_pressed(bind, device):
			return true
	return false

## Returns [code]true[/code] when a user starts pressing the [kbd]input[/kbd], 
## meaning it's true only on the frame the user pressed down the [kbd]input[/kbd].
func is_just_pressed(input: StringName, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_input_state(input, device):
		var input_state:
			if Engine.is_in_physics_frame():
				return input_state.is_pressed and input_state.physics_frame == Engine.get_physics_frames()
			else:
				return input_state.is_pressed and input_state.process_frame == Engine.get_process_frames()
		null:
			return false

## Returns [code]true[/code] if [kbd]input[/kbd] was just physically pressed
## meaning it's true only on the frame the user pressed down the [kbd]input[/kbd]
## and the [kbd]input[/kbd] was not triggered virtually.
func is_just_pressed_real(input: StringName, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_input_state(input, device):
		var input_state:
			return is_just_pressed(input, device) and not input_state.virtually_pressed
		null:
			return false

## Returns [code]true[/code] when the user stops pressing the [kbd]input[/kbd], 
## meaning it's true only on the frame that the user released the button.
func is_just_released(input: StringName, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_input_state(input, device):
		var input_state:
			if Engine.is_in_physics_frame():
				return not input_state.is_pressed and input_state.physics_frame == Engine.get_physics_frames()
			else:
				return not input_state.ispressed and input_state.process_frame == Engine.get_process_frames()
		null:
			return false

## Returns [code]true[/code] if device with given id is connected
func is_device_connected(device: int) -> bool:
	return _device_state_by_id.has(device)

## Returns a value between 0 and 1 representing the intensity of an [kbd]input[/kbd].
## If the [kbd]input[/kbd] has no range of strngth a discrete value of 0 or 1 will be returned.
func get_strength(input: StringName, device: int = DEVICE_KBM_JOY1) -> float:
	match _get_input_state(input, device):
		var input_state:
			return input_state.strength
		null:
			return 0.0

## Get axis input by specifiying two input names, one negative and one positive.
func get_axis(negative_input: StringName, positive_input: StringName, device: int = DEVICE_KBM_JOY1) -> float:
	return get_strength(positive_input, device) - get_strength(negative_input, device)

## Returns an array of all connected devices.
## This array always contains device 0 as this represents the keyboard and mouse.
func get_connected_devices() -> Array[int]:
	var connected_joypads := Input.get_connected_joypads()
	
	if connected_joypads.is_empty():
		connected_joypads.append(DEVICE_KBM_JOY1)
		
	return connected_joypads

## Sets [kbd]condition[/kbd] to given [kbd]value[/kbd]. Used for checking conditional inputs.
func set_condition(condition: String, value: bool, device: int = DEVICE_KBM_JOY1) -> void:
	match _get_device_state(device):
		var device_state:
			device_state.set_condition(condition, value)
		null:
			push_error("Failed to set condition. Unrecognized device '%d'" % device)

## Returns the state of a [kbd]condition[/kbd] set with set_condition.
func is_condition_true(condition: String, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_device_state(device):
		var device_state:
			return device_state.is_condition_true(condition)
		null:
			push_error("Failed to check condition. Unrecognized device '%d'" % device)
			return false

## Clears the condition dict.
func clear_conditions(device: int = DEVICE_KBM_JOY1) -> void:
	match _get_device_state(device):
		var device_state:
			device_state.clear_conditions()
		null:
			push_error("Failed to clear conditions. Unrecognized device '%d'" % device)

## Retruns a newly created virtual device.
## By convention all virtual devices are assigned a negative number.
func create_virtual_device() -> FrayVirtualDevice:
	# WARN: If I understand correctly hash is not truly unique so perhaps this could be an issue? Future me problem.
	var id := -_device_state_by_id.hash()
	var vd := FrayVirtualDevice.new(_connect_device(id), id)
	vd.disconnect_requested.connect(_on_VirtualDevice_disconnect_requested.bind(id))
	return vd


func _connect_device(device: int) -> FrayDeviceState:
	var device_state := FrayDeviceState.new()
	var all_input_names :=\
		(_input_map.get_bind_names() + _input_map.get_composite_input_names())
		
	for input_name in all_input_names:
		device_state.register_input_state(input_name)
	
	_device_state_by_id[device] = device_state
	
	device_connection_changed.emit(device, true)
	return device_state


func _disconnect_device(device: int) -> void:
	if _device_state_by_id.has(device):
		_device_state_by_id.erase(device)
		device_connection_changed.emit(device, false)
	else:
		push_error("Failed to disconnect device. Unrecognized device '%d'." % device)


func _get_device_state(device: int) -> FrayDeviceState:
	if _device_state_by_id.has(device):
		return _device_state_by_id[device]
	return null


func _get_input_state(input: String, device: int) -> FrayInputState:
	match _get_device_state(device):
		var device_state:
			if not _input_map.has_input(input):
				push_error("Failed to get input state. Unrecognized input '%s'" % input)
			return device_state.get_input_state(input)
		null:
			push_error("Failed to get input state. Unrecognized device '%d'" % device)
			return null


func _get_bind_state(input: String, device: int) -> FrayInputState:
	if _input_map.has_bind(input):
		return _get_input_state(input, device)
	return null


func _create_input_event(input: String, device: int) -> FrayInputEvent:
	var input_state := _get_input_state(input, device)
	var input_event := FrayInputEvent.new()

	if _input_map.has_bind(input):
		input_event = FrayInputEventBind.new()
		input_event.composites_used_in = input_state.composites_used_in
	elif _input_map.has_composite_input(input):
		input_event = FrayInputEventComposite.new()
		input_event.is_virtually_pressed = input_state.is_virtually_pressed

	input_event.device = device
	input_event.input = input
	input_event.time_pressed = input_state.time_pressed
	input_event.physics_frame = input_state.physics_frame
	input_event.process_frame = input_state.process_frame
	input_event.time_detected = Time.get_ticks_msec()
	input_event.is_pressed = input_state.is_pressed
	input_event.is_distinct = input_state.is_distinct
	
	return input_event


func _virtually_press(inputs: PackedStringArray, device: int) -> void:
	var device_state := _get_device_state(device)

	# Virtually press held binds
	for input in inputs:
		var input_state := _get_input_state(input, device)
		if input_state.pressed and not input_state.virtually_pressed:
			input_state.press(true)
			
	device_state.flag_inputs_as_distinct(inputs, true)
	
	# Virtually press composite inputs that uses held binds
	var is_atleast_one_composite_pressed := false
	for com_input_name in _input_map.get_composite_input_names():
		var com_input_state := _get_input_state(com_input_name, device)
		var com_input := _input_map.get_composite_input(com_input_name)
		var has_binds := com_input.can_decompose_into(device, _input_interface, inputs, false)

		if com_input_state.pressed and not com_input_state.virtually_pressed and has_binds:
			com_input_state.press(true)
			device_state.flag_inputs_use_in_composite(com_input_name, inputs)
			device_state.flag_inputs_as_distinct([com_input_name])

			if device_state.is_all_indistinct(inputs):
				device_state.unflag_inputs_as_distinct([com_input_name])
			else:
				device_state.unflag_inputs_as_distinct(inputs)


func _on_Input_joy_connection_changed(device: int, connected: bool) -> void:
	if device != DEVICE_KBM_JOY1:
		if connected:
			_connect_device(device)
		else:
			_disconnect_device(device)


func _on_VirtualDevice_disconnect_requested(id: int) -> void:
	_disconnect_device(id)
