extends Node
## Fray input manager singleton
##
## @desc:
## 		Functionally similar to Godot's built in `Input` singleton.

## Emitted when an input is detected
##
## input_event is a `FrayInputEvent` object containing information about the event
signal input_detected(input_event)

## Emitted when a device has been connected or disconnected
signal device_connection_changed(device_id, connected)

const DeviceState = preload("../device/device_state.gd")
const VirtualDevice = preload("../device/virtual_device.gd")
const InputState = preload("../device/input_data/state/input_state.gd")
const InputInterface = preload("../device/input_data/state/input_interface.gd")
const InputBindAction = preload("../device/input_data/binds/input_bind_action.gd")
const InputBindJoyAxis = preload("../device/input_data/binds/input_bind_joy_axis.gd")
const FrayInputEvent = preload("../events/fray_input_event.gd")
const FrayInputEventBind = preload("../events/fray_input_event_bind.gd")
const FrayInputEventComposite = preload("../events/fray_input_event_composite.gd")
const FrayInputMap = preload("fray_input_map.gd")

const DEVICE_KBM_JOY1 = 0

## Type: Dictionary<int, DeviceState>
var _device_state_by_id: Dictionary

onready var _input_map: FrayInputMap = get_node("../FrayInputMap")
onready var _input_interface := InputInterface.new(weakref(self))


func _ready() -> void:
	Input.connect("joy_connection_changed", self, "_on_Input_joy_connection_changed")

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
				if not input_state.pressed:
					input_state.press()
			elif input_state.pressed:
				input_state.unpress()
		
		for composite_input_name in _input_map.get_composite_input_names():
			var composite_input := _input_map.get_composite_input(composite_input_name)
			var input_state := device_state.get_input_state(composite_input_name)

			if composite_input.is_pressed(device, _input_interface):
				if not input_state.pressed:
					var my_components := composite_input.decompose(device, _input_interface)
					input_state.press()
					if device_state.has_all_filtered(my_components):
						device_state.filter([composite_input_name])
					else:
						device_state.filter(my_components)
			elif input_state.pressed:
				var my_components := composite_input.decompose(device, _input_interface)
				input_state.unpress()
				device_state.unfilter(my_components)
				device_state.unfilter([composite_input_name])

				if composite_input.is_virtual:
					var held_components: Array
					for bind in my_components:
						if is_pressed(bind, device):
							held_components.append(bind)

					var virtually_pressed_composite := false
					for com_input_name in _input_map.get_composite_input_names():
						var com_input_state := _get_input_state(com_input_name, device)
						var com_input := _input_map.get_composite_input(com_input_name)
						var has_binds := com_input.decomposes_into_binds(held_components, device, _input_interface)

						if com_input_state.pressed and has_binds:
							com_input_state.press(true)
							device_state.unfilter([com_input_name])
							virtually_pressed_composite = true
							break

					for bind in held_components:
						var bind_state := _get_input_state(bind, device)
						if bind_state.pressed:
							bind_state.press(true)

							if virtually_pressed_composite:
								device_state.filter([bind])
							break
		
		for input in device_state.get_all_inputs():
			if is_just_pressed(input, device) or is_just_released(input, device):
				var input_event := _create_input_event(input, device, device_state)
				input_event.echo = false
				emit_signal("input_detected", input_event)
			elif is_pressed(input, device):
				var input_event := _create_input_event(input, device, device_state)
				input_event.echo = true
				emit_signal("input_detected", input_event)

## Returns true if an input is being pressed.
func is_pressed(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_input_state(input, device):
		var input_state:
			return input_state.pressed
		null:
			return false

## Returns true if any of the inputs given are being pressed
func is_any_pressed(inputs: PoolStringArray, device: int = DEVICE_KBM_JOY1) -> bool:
	for input in inputs:
		if is_pressed(input):
			return true
	return false

## Returns true when a user starts pressing the input, 
## meaning it's true only on the frame the user pressed down the input.
func is_just_pressed(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_input_state(input, device):
		var input_state:
			if Engine.is_in_physics_frame():
				return input_state.pressed and input_state.physics_frame == Engine.get_physics_frames()
			else:
				return input_state.pressed and input_state.idle_frame == Engine.get_idle_frames()
		null:
			return false

## Returns true if input was physically pressed
## meaning it is only true if the press was not trigerred virtually.
func is_just_pressed_real(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_input_state(input, device):
		var input_state:
			return is_just_pressed(input, device) and not input_state.virtually_pressed
		null:
			return false

## Returns true when the user stops pressing the input, 
## meaning it's true only on the frame that the user released the button.
func is_just_released(input: String, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_input_state(input, device):
		var input_state:
			if Engine.is_in_physics_frame():
				return not input_state.pressed and input_state.physics_frame == Engine.get_physics_frames()
			else:
				return not input_state.pressed and input_state.idle_frame == Engine.get_idle_frames()
		null:
			return false

## Returns true if device with given id is connected
func is_device_connected(device: int) -> bool:
	 return _device_state_by_id.has(device)

## Returns a value between 0 and 1 representing the intensity of an input.
## If the input has no range of strngth a discrete value of 0 or 1 will be returned.
func get_strength(input: String, device: int = DEVICE_KBM_JOY1) -> float:
	match _get_input_state(input, device):
		var input_state:
			return input_state.strength
		null:
			return 0.0

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
	match _get_device_state(device):
		var device_state:
			device_state.set_condition(condition, value)
		null:
			push_error("Failed to set condition. Unrecognized device '%d'" % device)

## Returns the value of a condition set with set_condition.
func is_condition_true(condition: String, device: int = DEVICE_KBM_JOY1) -> bool:
	match _get_device_state(device):
		var device_state:
			return device_state.is_condition_true(condition)
		null:
			push_error("Failed to check condition. Unrecognized device '%d'" % device)
			return false

## Clears the condition dict
func clear_conditions(device: int = DEVICE_KBM_JOY1) -> void:
	match _get_device_state(device):
		var device_state:
			device_state.clear_conditions()
		null:
			push_error("Failed to clear conditions. Unrecognized device '%d'" % device)

## Retruns a newly created virtual device
## By convention all virtual devices are assigned a negative number
func create_virtual_device() -> VirtualDevice:
	# WARN: If I understand correctly hash is not truly unique so perhaps this could be an issue? Future me problem.
	var id := -_device_state_by_id.hash()
	var vd := VirtualDevice.new(_connect_device(id), id)
	vd.connect("disconnect_requested", self, "_on_VirtualDevice_disconnect_requested", [id])
	return vd


func _connect_device(device: int) -> DeviceState:
	var device_state := DeviceState.new()
	var all_input_names :=\
		(_input_map.get_bind_names() + _input_map.get_composite_input_names())
		
	for input_name in all_input_names:
		device_state.register_input_state(input_name)
	
	_device_state_by_id[device] = device_state

	emit_signal("device_connection_changed", device, true)
	return device_state


func _disconnect_device(device: int) -> void:
	if _device_state_by_id.has(device):
		_device_state_by_id.erase(device)
		emit_signal("device_connection_changed", true, false)
	else:
		push_error("Failed to disconnect device. Unrecognized device '%d'." % device)


func _get_device_state(device: int) -> DeviceState:
	if _device_state_by_id.has(device):
		return _device_state_by_id[device]
	return null


func _get_input_state(input: String, device: int) -> InputState:
	match _get_device_state(device):
		var device_state:
			if not _input_map.has_input(input):
				push_error("Failed to get input state. Unrecognized input '%s'" % input)
			return device_state.get_input_state(input)
		null:
			push_error("Failed to get input state. Unrecognized device '%d'" % device)
			return null


func _get_bind_state(input: String, device: int) -> InputState:
	if _input_map.has_bind(input):
		return _get_input_state(input, device)
	return null


func _create_input_event(input: String, device: int, device_state: DeviceState) -> FrayInputEvent:
	var input_state := _get_input_state(input, device)
	var input_event := FrayInputEvent.new()

	if _input_map.has_bind(input):
		input_event = FrayInputEventBind.new()
		input_event.is_overlapping = not device_state.has_filtered(input)
	elif _input_map.has_composite_input(input):
		input_event = FrayInputEventComposite.new()
		input_event.virtually_pressed = input_state.virtually_pressed

	input_event.device = device
	input_event.input = input
	input_event.time_pressed = input_state.time_pressed
	input_event.physics_frame = input_state.physics_frame
	input_event.idle_frame = input_state.idle_frame
	input_event.time_detected = OS.get_ticks_msec()
	input_event.pressed = input_state.pressed
	
	return input_event

func _on_Input_joy_connection_changed(device: int, connected: bool) -> void:
	if device != DEVICE_KBM_JOY1:
		if connected:
			_connect_device(device)
		else:
			_disconnect_device(device)


func _on_VirtualDevice_disconnect_requested(id: int) -> void:
	_disconnect_device(id)
