@tool
@icon("res://addons/fray/assets/icons/combat_state_machine.svg")
class_name FrayCombatStateMachine
extends FrayStateMachine
## Combat state machine
##
## A state machine which can contain and switch between multiple situations based on buffered inputs.
## A situation is a [FraySituationState] which represents the set of actions avilable to a combatant.
## For example, in many fighting games the actions a combatant can perform when situated on the ground differ
## from when they're in the air.
## [br]
## When adding situations it is recommended to build the state using the [FraySituationStateBuilder].
## [br][br]
## Example:
## [codeblock]
## var builder := Fray.State.CombatSituationBuilder.new()
## combat_sm.add_situation("on_ground", builder
## 	.transition_button("idle", "punch1", "square")
## 	.transition_button("punch1", "punch2", "square", {prereqs = [FrayCondition.new("on_hit")]})
## 	.build()
## 	)
##  [/codeblock]

## Allow transitions transitions to occur in the root state machine.
## Enabling and disabling this property allows you to control when a combatant
## is allowed to transition into the next buffered state.
## This can be used to control when a player is allowed to 'cancel' an attack.
@export var allow_transitions: bool = false

## The max time a detected input can exist in the buffer before it is ignored in milliseconds.
@export var input_max_buffer_time_ms: int = 1000

## Name of the state machine's surrent situation
var current_situation: StringName:
	set(situation_name):
		if not has_situation(situation_name):
			push_error("Failed to change situation. State machine does not contain situation named '%s'" % situation_name)
			return
		
		if situation_name != current_situation:
			current_situation = situation_name
			_root = get_situation(situation_name)
			_root.goto_start()

# Type: Dictionary<StringName, FraySituationState>
# Hint: <situation name, >
var _situations: Dictionary

var _root: FraySituationState
var _input_buffer: Array[BufferedInput]
var _time_since_last_input_ms: float


func _get_root_impl() -> FrayRootState:
	return _root


func _advance_impl(input: Dictionary = {}, args: Dictionary = {})  -> void:
	super(input, args)
	
	var current_time := Time.get_ticks_msec()
	while not _input_buffer.is_empty() and allow_transitions:
		var buffered_input: BufferedInput = _input_buffer.pop_front()
		var time_since_last_input = (current_time - _time_since_last_input_ms) / 1000.0
		var time_since_inputted: int = current_time - buffered_input.time_stamp
		var next_state := _get_next_state(buffered_input, time_since_last_input)
		
		if not next_state.is_empty() and time_since_inputted <= input_max_buffer_time_ms:
			_root.goto(next_state)
			_time_since_last_input_ms = current_time
			break


## Returns the current situation to its start state.
## [br]
## Shorthand for _root.goto_start()
func goto_start_state() -> void:
	if _root != null:
		_root.goto_start()

## Adds a combat situation to the state machine.
func add_situation(situation_name: StringName, state: FraySituationState) -> void:
	if has_situation(situation_name):
		push_warning("Combat situation name '%s' already exists.")
		return

	_situations[situation_name] = state

	if _situations.size() == 1:
		change_situation(situation_name)

## Changes the currently activate situation
func change_situation(situation_name: StringName) -> void:
	if not has_situation(situation_name):
		push_error("Failed to change situation. State machine does not contain situation named '%s'" % situation_name)
		return
	
	if situation_name != current_situation:
		current_situation = situation_name
		_root = get_situation(situation_name)
		_root.goto_start()

## Returns a situation with the given name if it exists.
func get_situation(situation_name: StringName) -> FraySituationState:
	if has_situation(situation_name):
		return _situations[situation_name]
	return null

## Returns true if a situation with the given name exists
func has_situation(situation_name: StringName) -> bool:
	return _situations.has(situation_name)


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


func _get_next_state(buffered_input: BufferedInput, time_since_last_input: float) -> StringName:
	if buffered_input is BufferedInputButton:
		return _root.get_next_state({
			input = buffered_input.input,
			input_is_pressed = buffered_input.is_pressed,
			time_since_last_input = time_since_last_input,
			time_held = (Time.get_ticks_msec() - buffered_input.time_stamp) / 1000.0
		})
	elif buffered_input is BufferedInputSequence:
		return _root.get_next_state({
			sequence = buffered_input.sequence,
			time_since_last_input = time_since_last_input,
		})
	return ""


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
