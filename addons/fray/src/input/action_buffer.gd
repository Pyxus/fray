class_name FrayActionBuffer
extends Node

#TODO: Move action buffer to input singleton
#TODO: Add action window to input singleton.
#A buffer repeats an input for x frames. a Window accepts an input for x frames

# Type: Dictionary<StringName, _ActionBuffer>
var _timer_by_action: Dictionary

@onready var _fray_input: _FrayInput = get_node_or_null("/root/FrayInput")

func _ready() -> void:
	if _fray_input == null:
		push_error("Failed to access FrayInput singleton. Fray plugin may not be enabled.")
		return


func register(action: StringName, input: StringName, max_buffer_time: float) -> void:
	_timer_by_action[action] = _ActionBuffer.new(input, max_buffer_time, get_tree().create_timer)
	_fray_input.input_detected.connect(_timer_by_action[action]._on_FrayInput_input_detected)


func is_pressed(action: StringName, can_direct_check: bool = true) -> bool:
	var buffer: _ActionBuffer = _timer_by_action.get(action)
	var buffer_pressed := buffer.is_pressed if buffer else false
	return buffer_pressed or false

## Consumes the action preventing it from being pressed until reset
func consume(action: StringName) -> void:
	var buffer: _ActionBuffer = _timer_by_action.get(action)
	if buffer:
		buffer.consume()
	
#func is_pressed(action: StringName, reset_condition: Callable = null) -> bool:
#	var buffer: _ActionBuffer = _timer_by_action.get(action)
#	var pressed := (buffer.is_pressed and can_reset) if buffer else false
#
#	if can_reset:
#		reset(action)
#
#	return pressed

func reset(action: StringName) -> void:
	var buffer: _ActionBuffer = _timer_by_action.get(action)
	if buffer != null:
		buffer.reset()


class _ActionBuffer:
	extends RefCounted
	
	var input: StringName
	var max_buffer_time: float
	var create_timer: Callable
	var is_pressed: bool
	var is_consumed: bool
	
	var _timer: SceneTreeTimer


	func _init(input: StringName, max_buffer_time: float, create_timer: Callable) -> void:
		self.input = input
		self.max_buffer_time = max_buffer_time
		self.create_timer = create_timer
	
	
	func reset() -> void:
		is_pressed = false
		is_consumed = false
		kill_timer()
	
	
	func consume() -> void:
		is_pressed = false
		is_consumed = true
		kill_timer()
	
	
	func kill_timer() -> void:
		if _timer != null:
			for connection in _timer.timeout.get_connections():
				_timer.timeout.disconnect(connection.callable)
			_timer = null
		
		
	func _on_FrayInput_input_detected(input_event: FrayInputEvent) -> void:
		if input_event.is_just_pressed() and input == input_event.input and not is_pressed and not is_consumed:
			is_pressed = true
			_timer = create_timer.call(max_buffer_time)
			_timer.timeout.connect(reset)
