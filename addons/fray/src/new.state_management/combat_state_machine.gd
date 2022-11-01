tool
extends "state_machine.gd"

const StateCombatSituation = preload("state/state_combat_situation.gd")

## Allow transitions transitions to occur in the state machine.
## Enabling and disabling this property allows you to control when a combatant
## is allowed to transition into the next buffered state.
## This can be used to control when a player is allowed to 'cancel' an attack.
export var allow_transitions: bool

## The max number of detected inputs that can be buffered.
export var max_buffered_transitions: int = 1

## The max time a detected input can exist in the buffer before it is ignored in frames.
## Here a frame is defined as '1 / physics_fps'
export var input_max_buffer_time: int = 5 setget set_input_max_buffer_time

## The max time a detected input can exist in the buffer before it is ignored in ms.
export var input_max_buffer_time_ms: int = 1000 setget set_input_max_buffer_time_ms

## Type: BufferedInput[]
var _input_buffer: Array

## Type: String[]
var _state_buffer: Array


## Setter for 'input_max_buffer_time' property
func set_input_max_buffer_time(value: int) -> void:
	input_max_buffer_time = value
	input_max_buffer_time_ms = round((input_max_buffer_time / Engine.iterations_per_second) * 1000)

## Setter for 'input_max_buffer_time_ms' property
func set_input_max_buffer_time_ms(value: int) -> void:
	input_max_buffer_time_ms = value
	input_max_buffer_time = round(Engine.iterations_per_second * input_max_buffer_time_ms) * 1000

## Buffers an input button to be processed by the state machine
func buffer_button(input: String, is_released: bool = false) -> void:
	_input_buffer.append(BufferedInputButton.new(OS.get_ticks_msec(), input, is_released))

## Buffers an input sequence to be processed by the state machine
func buffer_sequence(sequence_name: String) -> void:
	_input_buffer.append(BufferedInputSequence.new(OS.get_ticks_msec(), sequence_name))

## Clears the current buffered inputs and buffered state
func clear_buffer() -> void:
	_state_buffer.clear()
	_input_buffer.clear()

func _advance_impl(input: Dictionary = {}, args: Dictionary = {})  -> void:
	if not active:
		return
	
	if root.get_current_state() == null:
		push_warning("Failed to advance. Current state not set.")
		return
	
	var current_time := OS.get_ticks_msec()

	if allow_transitions:
		while not _input_buffer.empty() and _state_buffer.size() <= max_buffered_transitions:
			var buffered_input: BufferedInput = _input_buffer.pop_front()
			var next_state: String 

			if buffered_input is BufferedInputButton:
				next_state = root.get_next_state({
					input = buffered_input.input,
					input_is_pressed = buffered_input.is_pressed,
					time_since_last_input = 0
				})
			elif buffered_input is BufferedInputSequence:
				next_state = root.get_next_state({
					input = buffered_input.sequence_name,
					time_since_last_input = 0,
				})

			var time_since_inputted: int = current_time - buffered_input.time_stamp

			if not next_state.empty() and time_since_inputted <= input_max_buffer_time_ms:
				_state_buffer.append(next_state)
				break
	
	if not _state_buffer.empty():
		root.go_to(_state_buffer.pop_front())


class BufferedInput:
	extends Reference

	func _init(input_time_stamp: int = 0) -> void:
		time_stamp = input_time_stamp
	
	var time_stamp: int
	

class BufferedInputButton:
	extends BufferedInput

	func _init(input_time_stamp: int = 0, input_name: String = "", input_is_pressed: bool = true).(input_time_stamp) -> void:
		input = input_name
		is_pressed = input_is_pressed
	
	var input: String
	var is_pressed: bool


class BufferedInputSequence:
	extends BufferedInput

	func _init(input_time_stamp: int = 0, input_sequence_name: String = "").(input_time_stamp) -> void:
		sequence_name = input_sequence_name
	
	var sequence_name: String