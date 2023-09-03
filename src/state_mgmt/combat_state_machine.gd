@tool
@icon("res://addons/fray/assets/icons/combat_state_machine.svg")
class_name FrayCombatStateMachine
extends FrayStateMachine
## Combat state machine
##
## A state machine which can contain and switch between multiple situations based on buffered inputs.
## A situation is a [FrayRootState] which represents the set of actions avilable to a combatant.
## For example, in many fighting games the actions a combatant can perform when situated on the ground differ
## from when they're in the air.
## [br]
## When adding situations it is recommended to build the state using the [FrayRootState.Builder].
## [br][br]
## Example:
## [codeblock]
## combat_sm.add_situation("on_ground", FrayRootState.builder()
## 	.transition_button("idle", "punch1", "square")
## 	.transition_button("punch1", "punch2", "square", {prereqs = [FrayCondition.new("on_hit")]})
## 	.build()
## 	)
##  [/codeblock]

## Emitted when the current situation changes
signal situation_changed(from: StringName, to: StringName)

## Allow transitions transitions to occur in the root state machine.
## Enabling and disabling this property allows you to control when a combatant
## is allowed to transition into the next buffered state.
## This can be used to control when a player is allowed to 'cancel' an attack.
@export var allow_transitions: bool = false

## The max time a detected input can exist in the buffer before it is ignored in milliseconds.
@export_range(0, 5000, 1, "suffix:ms") var input_max_buffer_time: int = 1000

## Name of the state machine's surrent situation
var current_situation: StringName:
	set(situation_name):
		if not has_situation(situation_name):
			push_error("Failed to change situation. State machine does not contain situation named '%s'" % situation_name)
			return
		
		if situation_name != current_situation:
			var prev_sitch := current_situation
			current_situation = situation_name
			_root = get_situation(situation_name)
			_root.goto_start()
			situation_changed.emit(prev_sitch, current_situation)

# Type: Dictionary<StringName, FraySituationState>
# Hint: <situation name, >
var _situations: Dictionary

var _input_buffer: Array[BufferedInput]
var _time_since_last_input_msec: float


func _advance_impl(input: Dictionary = {}, args: Dictionary = {})  -> void:
	super(input, args)
	
	var current_time := Time.get_ticks_msec()
	while not _input_buffer.is_empty() and allow_transitions:
		var buffered_input: BufferedInput = _input_buffer.pop_front()
		var time_since_last_input = (current_time - _time_since_last_input_msec) / 1000.0
		var time_since_inputted: int = current_time - buffered_input.time_stamp
		var next_state := _get_next_state(buffered_input, time_since_last_input)
		
		if not next_state.is_empty() and time_since_inputted <= input_max_buffer_time:
			_root.goto(next_state)
			_time_since_last_input_msec = current_time
			break

## Adds a combat situation to the state machine.
func add_situation(situation_name: StringName, state: FrayRootState) -> void:
	if has_situation(situation_name):
		push_warning("Combat situation name '%s' already exists.")
		return

	_situations[situation_name] = state

	state.transitioned.connect(_on_RootState_transitioned)

	if _situations.size() == 1:
		change_situation(situation_name)

## Changes the currently activate situation
func change_situation(situation_name: StringName, reset_previous_situation :bool = false)  -> void:
	if not has_situation(situation_name):
		push_error("Failed to change situation. State machine does not contain situation named '%s'" % situation_name)
		return

	if situation_name != current_situation:
		if(_root != null and reset_previous_situation):
			_root._exit_impl()
			_root._current_state = ''
		current_situation = situation_name

## Returns a situation with the given name if it exists.
func get_situation(situation_name: StringName) -> FrayRootState:
	if has_situation(situation_name):
		return _situations[situation_name]
	return null

## Returns the current situation
func get_current_situation() -> FrayRootState:
	if has_situation(current_situation):
		return _situations[current_situation]
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


func _set_root(value: FrayRootState) -> void:
	assert(false, "The root is managed by the CombatStateMachine. See the `add_situation` and `change_situation` methods to update it.")
	pass

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
			sequence = buffered_input.sequence_name,
			time_since_last_input = time_since_last_input,
		})
	return ""


func _on_RootState_transitioned(from: StringName, to: StringName) -> void:
	state_changed.emit(from, to)


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
