#TODO: Design new icon for this node
@icon("res://addons/fray/assets/icons/combat_state_machine.svg")
class_name FrayBufferedInputAdvancer
extends Node
## A node which attempts to advance a given state machine using buffered inputs.

enum AdvanceMode{
	IDLE, ## Advance during the idle process
	PHYSICS, ## Advance during the physics process
}

## The state machine to be controlled by the advancer
@export var state_machine: FrayStateMachine

## If true buffer is allowed to attempt to advance by feeding state machine inputs.
## Enabling and disabling this property allows you to control when buffered inputs are consumed.
## This can be used to control when a player is able to 'cancel' an attack using the inputs they buffered.
@export var paused: bool = true

## The max time a detected input can exist in the buffer before it is ignored, in milliseconds.
@export_range(0, 5000, 1, "suffix:ms") var max_buffer_time: int = 1000

## Determines the process during which the advancer machine can advance the state machine.
@export var advance_mode: AdvanceMode

var _input_buffer: Array[BufferedInput]
var _time_since_last_input_msec: float


func _process(delta: float) -> void:
	if advance_mode == AdvanceMode.IDLE:
		_advance()


func _physics_process(delta: float) -> void:
	if advance_mode == AdvanceMode.PHYSICS:
		_advance()

## Buffers an input button to be processed by the state machine
##
## [kbd]input[/kbd] is the name of the input.
## This is just an identifier used in input transitions.
## It is not default associated with any actions in godot or inputs in fray.
##
## If [kbd]is_presse[/kbd] is true then a pressed input is buffered, else a released input is buffered.
func buffer_button(input: StringName, is_pressed: bool = true) -> void:
	_input_buffer.append(BufferedInputButton.new(Time.get_ticks_msec(), input, is_pressed))

## Buffers an input sequence to be processed by the state machine
#
## [kbd]sequence_name[/kbd] is the name of the sequence.
## This is just an identifier used in input transitions.
## It is not default associated with any actions in godot or inputs in fray.
func buffer_sequence(sequence_name: StringName) -> void:
	_input_buffer.append(BufferedInputSequence.new(Time.get_ticks_msec(), sequence_name))

## Clears the input buffer
func clear_buffer() -> void:
	_input_buffer.clear()

## Returns the current state of the buffer.
## The returned buffer objects are not copies.
func get_buffer() -> Array[BufferedInput]:
	return _input_buffer.duplicate()


func _advance()  -> void:
	var current_time := Time.get_ticks_msec()

	while not _input_buffer.is_empty() and not paused:
		var buffered_input: BufferedInput = _input_buffer.pop_front()
		var time_since_last_input = (current_time - _time_since_last_input_msec) / 1000.0
		var time_since_inputted: int = current_time - buffered_input.time_stamp
		var advance_input := _create_advance_input(buffered_input, time_since_last_input)
	
		if state_machine.advance(advance_input):
			_time_since_last_input_msec = current_time
			break

func _create_advance_input(buffered_input: BufferedInput, time_since_last_input: float) -> Dictionary:
	if buffered_input is BufferedInputButton:
		return {
			input = buffered_input.input,
			input_is_pressed = buffered_input.is_pressed,
			time_since_last_input = time_since_last_input,
			time_held = (Time.get_ticks_msec() - buffered_input.time_stamp) / 1000.0
		}
	elif buffered_input is BufferedInputSequence:
		return {
			sequence = buffered_input.sequence_name,
			time_since_last_input = time_since_last_input,
		}
	return {}

class BufferedInput:
	extends RefCounted

	func _init(input_time_stamp: int = 0) -> void:
		time_stamp = input_time_stamp
	
	var time_stamp: int
	

class BufferedInputButton:
	extends BufferedInput

	func _init(input_time_stamp: int = 0, input_name: StringName = "", input_is_pressed: bool = true) -> void:
		super(input_time_stamp)
		input = input_name
		is_pressed = input_is_pressed
	
	var input: StringName
	var is_pressed: bool


class BufferedInputSequence:
	extends BufferedInput

	func _init(input_time_stamp: int = 0, input_sequence_name: StringName = "") -> void:
		super(input_time_stamp)
		sequence_name = input_sequence_name
	
	var sequence_name: StringName
