class_name FrayInputBuffer
extends Node

#TODO: Move action buffer to input singleton
#TODO: Add action window to input singleton.
#A buffer repeats an input for x frames. a Window accepts an input for x frames

@export var device: int

# Type: Dictionary<StringName, _InputWindow>
var _window_by_input: Dictionary

# Type: Dictionary<StringName, _InputBuffer>
var _buffer_by_input: Dictionary

@onready var _fray_input: _FrayInput = get_node_or_null("/root/FrayInput")
@onready var _fray_input_map: _FrayInputMap = get_node_or_null("/root/FrayInputMap")

func _ready() -> void:
	if _fray_input == null:
		push_error("Failed to access FrayInput singleton. Fray plugin may not be enabled.")
		return
	
	if _fray_input_map == null:
		push_error("Failed to access FrayInputMap singleton. Fray plugin may not be enabled.")


func _physics_process(delta: float) -> void:
	for input in _buffer_by_input:
		var buffer: _InputBuffer = _buffer_by_input[input]
		
		if buffer.is_pressed and (buffer.is_expired() or buffer.can_consume.call()):
			buffer.reset()

##
func set_buffer(input: StringName, duration: float, can_consume: Callable = func(): return false) -> void:
	_WARN_INPUT_DOES_NOT_EXIST(input)
	
	var buffer: _InputBuffer = _buffer_by_input.get(input, _InputBuffer.new())
	buffer.input = input
	buffer.duration = duration
	buffer.can_consume = can_consume

	_buffer_by_input[input] = buffer
	
	if not _fray_input.input_detected.is_connected(buffer._on_FrayInput_input_detected):
		_fray_input.input_detected.connect(buffer._on_FrayInput_input_detected)

##
## An input window is a period of time during which an input is still allowed
func set_window(input: StringName, duration: float, can_consume: Callable = func(): return false) -> void:
	_WARN_INPUT_DOES_NOT_EXIST(input)
	
	var window: _InputWindow = _window_by_input.get(input, _InputWindow.new())
	window.input = input
	window.duration = duration
	window.can_consume = can_consume
	
	_window_by_input[input] = window
	
	if not _fray_input.input_detected.is_connected(window._on_FrayInput_input_detected):
		_fray_input.input_detected.connect(window._on_FrayInput_input_detected)


func is_press_buffered(input: StringName) -> bool:
	match _buffer_by_input.get(input):
		var buffer:
			return buffer.is_pressed and not buffer.is_expired()
		null:
			return false


func is_press_in_window(input: StringName) -> bool:
	match _window_by_input.get(input):
		var window:
			return window.is_pressed
		null:
			return false


func reset_buffer(input: StringName) -> void:
	match _buffer_by_input.get(input):
		var buffer:
			buffer.time_started = Time.get_ticks_msec()
			buffer.is_pressed = false
		null:
			push_warning("Failed to reset buffer. A buffer was never set for input %s" % input)
	
	
func reset_window(input: StringName) -> void:
	match _window_by_input.get(input):
		var window:
			window.time_started = Time.get_ticks_msec()
		null:
			push_warning("Failed to reset window. A window was never set for input %s" % input)


func erase_buffer(input: StringName) -> void:
	_buffer_by_input.erase(input)


func erase_window(input: StringName) -> void:
	_window_by_input.erase(input)


func clear_buffer() -> void:
	_buffer_by_input.clear()


func clear_window() -> void:
	_window_by_input.clear()
	

func _WARN_INPUT_DOES_NOT_EXIST(input: StringName) -> bool:
	if not _fray_input_map.has_input(input):
		push_warning("Input %s does not exist. Consider adding a bind or composite input to the FrayInputMap" % input)
		return true
	return false


class _InputBuffer:
	extends RefCounted
	
	var device: int
	var time_started: int
	var duration: float
	var input: StringName
	var is_pressed: bool
	var can_consume: Callable
	
	func is_expired() -> bool:
		return time_started + duration * 1000 - Time.get_ticks_msec() < 0
	
	
	func reset() -> void:
		time_started = Time.get_ticks_msec()
		is_pressed = false
	
	
	func _is_pressed(input_event: FrayInputEvent) -> bool:
		return(
			input_event.device == device 
			and not is_pressed
			and input_event.is_just_pressed() 
			and input_event.input == input 
		)
	
	func _on_FrayInput_input_detected(input_event: FrayInputEvent) -> void:
		if _is_pressed(input_event):
			is_pressed = true
				


class _InputWindow:
	extends RefCounted
	
	var device: int
	var time_started: int
	var input: StringName
	var can_consume := func(): return false
	var duration: float
	var is_pressed: bool


	func _is_input_in_window(input_event: FrayInputEvent) -> bool:
		return(
			not is_pressed
			and input_event.input == input 
			and input_event.is_just_pressed()
			and time_started > 0
			and input_event.time_pressed - time_started <= duration * 1000
			)


	func _on_FrayInput_input_detected(input_event: FrayInputEvent) -> void:
		if input_event.device == device:
			if _is_input_in_window(input_event):
				is_pressed = true
			elif is_pressed and can_consume.call():
				is_pressed = false
				time_started = 0
			else:
				is_pressed = false
