class_name FrayInputBuffer
extends Node
## Experimental input buffer node
##
## Allows the creation and use of input buffers and windows.

## The ID of the device to check for## 
@export var device: int = _FrayInput.DEVICE_KBM_JOY1

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
		
		if buffer.is_pressed and (buffer.is_expired() or buffer.can_reset()):
			buffer.reset()
	
	for input in _window_by_input:
		var window: _InputWindow = _window_by_input[input]
		
		if window.is_pressed and window.can_end():
			window.end()
		
		if window.can_start():
			start_window(input)
		
## Sets a buffer for the given [kbd]input[/kbd] that lasts for a given [kbd]duration[/kbd] in ms.
## [br]
## A buffer repeats an input for a certain amount of time after the input is pressed.
## This is useful for applications such as jump buffering where a jump can still be performed
## even if the player presses the jump button a few frames before landing.
## [br][br]
## [kbd]can_reset[/kbd] is a function which if [code]true[/code] will
## automatically reset the buffer if a input press has been buffered.
## Buffers will also reset when they outlive their duration.
func set_buffer(input: StringName, duration: int, can_reset := Callable()) -> void:
	_WARN_INPUT_DOES_NOT_EXIST(input)
	
	var buffer: _InputBuffer = _buffer_by_input.get(input, _InputBuffer.new())
	buffer.input = input
	buffer.duration = duration
	buffer.func_can_reset = can_reset

	_buffer_by_input[input] = buffer
	
	if not _fray_input.input_detected.is_connected(buffer._on_FrayInput_input_detected):
		_fray_input.input_detected.connect(buffer._on_FrayInput_input_detected)

## Sets a window for the given [kbd]input[/kbd] that lasts for a given [kbd]duration[/kbd] in ms.
## [br]
## A window allows can input to be accepted if performed within a certain time frame.
## This is useful for applications such as coyote time where jumping is still allowed a few frames
## After walking off a ledge.
## To start a window see [method start_window].
## [br][br]
## [kbd]can_start[/kbd] is a function which will automatically start the window when [code]true[/code].
## [br][br]
## [kbd]can_end[/kbd] is a function which if [code]true[/code] will
## automatically end the window if a press occurs within the window's duration.
## Windows will also end when they outlive their duration.
func set_window(input: StringName, duration: int, can_start := Callable(), can_end := Callable()) -> void:
	_WARN_INPUT_DOES_NOT_EXIST(input)
	
	var window: _InputWindow = _window_by_input.get(input, _InputWindow.new())
	window.input = input
	window.duration = duration
	window.func_can_end = can_end
	window.func_can_start = can_start
	
	_window_by_input[input] = window
	
	if not _fray_input.input_detected.is_connected(window._on_FrayInput_input_detected):
		_fray_input.input_detected.connect(window._on_FrayInput_input_detected)

## Returns [code]true[/code] if the given input has been buffered.
func is_press_buffered(input: StringName) -> bool:
	match _buffer_by_input.get(input):
		var buffer:
			return buffer.is_pressed and not buffer.is_expired()
		null:
			return false

## Returns [code]true[/code] if the given input is being pressed or has been buffered.
func is_pressed_or_buffered(input: StringName) -> bool:
	return is_press_buffered(input) or _fray_input.is_pressed(input, device)

## Returns [code]true[/code] if the given input was pressed within the last window.
func is_press_in_window(input: StringName) -> bool:
	match _window_by_input.get(input):
		var window:
			return window.is_pressed
		null:
			return false

## Resets the buffer for the given [kbd]input[/kbd] if a buffer was set.
## See [method set_buffer]
func reset_buffer(input: StringName) -> void:
	match _buffer_by_input.get(input):
		var buffer:
			buffer.time_started = Time.get_ticks_msec()
			buffer.is_pressed = false
		null:
			push_warning("Failed to reset buffer. A buffer was never set for input %s" % input)
	
## Starts the buffer for the given [kbd]input[/kbd] if a window was set.
## See [method set_window]
func start_window(input: StringName) -> void:
	match _window_by_input.get(input):
		var window:
			window.time_started = Time.get_ticks_msec()
		null:
			push_warning("Failed to start window. A window was never set for input %s" % input)

## Erases a set buffer.
func erase_buffer(input: StringName) -> void:
	_buffer_by_input.erase(input)

## Erases a set window.
func erase_window(input: StringName) -> void:
	_window_by_input.erase(input)

## Clears all set buffers.
func clear_buffer() -> void:
	_buffer_by_input.clear()

## Clears all set windows.
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
	var duration: int
	var input: StringName
	var is_pressed: bool
	var func_can_reset: Callable
	
	func can_reset() -> bool:
		return func_can_reset.is_valid() and func_can_reset.call()
	
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
	var func_can_end: Callable
	var func_can_start: Callable
	var duration: float
	var is_pressed: bool
	
	
	func can_end() -> bool:
		return func_can_end.is_valid() and func_can_end.call()
	
	
	func can_start() -> bool:
		return func_can_start.is_valid() and func_can_start.call()
		
		
	func end() -> void:
		is_pressed = false
		time_started = 0

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
			else:
				is_pressed = false
