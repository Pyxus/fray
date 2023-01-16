@tool
extends "state_machine.gd"
## Combat state machine
##
## @desc:
##		A state machine which can contain and switch between multiple situations.
##		A situation is a `StateNodeStateMachineGlobal` that represents the set of actions avilable to a combatant.
##		For example, in many fighting games the actions a combatant can perform when situated on the ground differ
##		from when they're in the air.
##
##		When adding situations it is recommended to build the state node using the `CombatSituationBuilder`.
##		Example:
##			var builder := Fray.State.CombatSituationBuilder.new()
##			combat_sm.add_situation("on_ground", builder\
##				.transition_button("idle", "punch1", "square")\
##				.transition_button("punch1", "punch2", "square", {prereqs = [Fray.State.Condition.new("on_hit")]})
##				.build()
##			)

const StateNodeStateMachineGlobal = preload("node/state_node_state_machine_global.gd")

## Allow transitions transitions to occur in the root state machine.
## Enabling and disabling this property allows you to control when a combatant
## is allowed to transition into the next buffered state.
## This can be used to control when a player is allowed to 'cancel' an attack.
@export var allow_transitions: bool

## The max time a detected input can exist in the buffer before it is ignored in frames.
## Here a frame is defined as '1 / physics_fps'
@export var input_max_buffer_time: int = 5:
	set(value):
		input_max_buffer_time = value
		input_max_buffer_time_ms = floor((input_max_buffer_time / float(Engine.iterations_per_second)) * 1000)
		property_list_changed_notify()

## The max time a detected input can exist in the buffer before it is ignored in ms.
@export var input_max_buffer_time_ms: int = 1000:
	set(value):
		input_max_buffer_time_ms = value
		input_max_buffer_time = ceil((Engine.iterations_per_second * input_max_buffer_time_ms) / 1000.0)
		property_list_changed_notify()

## Name of the state machine's surrent situation
var current_situation: String:
	set(situation_name):
		if not has_situation(situation_name):
			push_error("Failed to change situation. State machine does not contain situation named '%s'" % situation_name)
			return
		
		if situation_name != current_situation:
			current_situation = situation_name
			root = get_situation(situation_name)
			root.goto_start()
		

## Type: BufferedInput[]
var _input_buffer: Array

## Type: Dictionary<String, StateNodeStateMachineGlobal>
## Hint: <situation name, >
var _situations: Dictionary

var _time_since_last_input_ms: float


func _advance_impl(input: Dictionary = {}, args: Dictionary = {})  -> void:
	super(input, args)
	
	var current_time := OS.get_ticks_msec()
	while not _input_buffer.empty() and allow_transitions:
		var buffered_input: BufferedInput = _input_buffer.pop_front()
		var time_since_last_input = (current_time - _time_since_last_input_ms) / 1000.0
		var time_since_inputted: int = current_time - buffered_input.time_stamp
		var next_state := _get_next_state(buffered_input, time_since_last_input)
		
		if not next_state.empty() and time_since_inputted <= input_max_buffer_time_ms:
			root.goto(next_state)
			_time_since_last_input_ms = current_time
			break


func set_root(value: StateNodeStateMachine) -> void:
	super(value)
	push_warning("The CombatStateMachine changes the root internally based on the current situation. You should not need to set it directly.")

## Returns the current situation to its start state.
## Shorthand for root.goto_start()
func goto_start_state() -> void:
	if root != null:
		root.goto_start()

## Adds a combat situation to the state machine.
func add_situation(situation_name: String, node: StateNodeStateMachineGlobal) -> void:
	if has_situation(situation_name):
		push_warning("Combat situation name '%s' already exists.")
		return

	_situations[situation_name] = node

	if _situations.size() == 1:
		change_situation(situation_name)

## Changes the currently activate situation
func change_situation(situation_name: String) -> void:
	if not has_situation(situation_name):
		push_error("Failed to change situation. State machine does not contain situation named '%s'" % situation_name)
		return
	
	if situation_name != current_situation:
		current_situation = situation_name
		root = get_situation(situation_name)
		root.goto_start()

## Returns a situation with the given name if it exists.
func get_situation(situation_name: String) -> StateNodeStateMachineGlobal:
	if has_situation(situation_name):
		return _situations[situation_name]
	return null


## Returns true if a situation with the given name exists
func has_situation(situation_name: String) -> bool:
	return _situations.has(situation_name)

## Setter for 'input_max_buffer_time' property
func set_input_max_buffer_time(value: int) -> void:
	input_max_buffer_time = value
	input_max_buffer_time_ms = floor((input_max_buffer_time / float(Engine.iterations_per_second)) * 1000)
	property_list_changed_notify()
	

## Setter for 'input_max_buffer_time_ms' property
func set_input_max_buffer_time_ms(value: int) -> void:
	input_max_buffer_time_ms = value
	input_max_buffer_time = ceil((Engine.iterations_per_second * input_max_buffer_time_ms) / 1000.0)
	property_list_changed_notify()

## Buffers an input button to be processed by the state machine
##
## `input` is the name of the input.
## This is just an identifier used in input transitions.
## It is not default associated with any actions in godot or inputs in fray.
##
## If `is_pressed` is true then a pressed input is buffered, else a released input is buffered.
func buffer_button(input: String, is_pressed: bool = true) -> void:
	_input_buffer.append(BufferedInputButton.new(OS.get_ticks_msec(), input, is_pressed))

## Buffers an input sequence to be processed by the state machine
#
## `sequence_name` is the name of the sequence.
## This is just an identifier used in input transitions.
## It is not default associated with any actions in godot or inputs in fray.
func buffer_sequence(sequence_name: String) -> void:
	_input_buffer.append(BufferedInputSequence.new(OS.get_ticks_msec(), sequence_name))

## Clears the input buffer
func clear_buffer() -> void:
	_input_buffer.clear()


func _get_next_state(buffered_input: BufferedInput, time_since_last_input: float) -> String:
	if buffered_input is BufferedInputButton:
		return root.get_next_node({
			input = buffered_input.input,
			input_is_pressed = buffered_input.is_pressed,
			time_since_last_input = time_since_last_input
		})
	elif buffered_input is BufferedInputSequence:
		return root.get_next_node({
			input = buffered_input.sequence_name,
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

	func _init(input_time_stamp: int = 0, input_name: String = "", input_is_pressed: bool = true) -> void:
		super(input_time_stamp)
		input = input_name
		is_pressed = input_is_pressed
	
	var input: String
	var is_pressed: bool


class BufferedInputSequence:
	extends BufferedInput

	func _init(input_time_stamp: int = 0, input_sequence_name: String = "") -> void:
		super(input_time_stamp)
		sequence_name = input_sequence_name
	
	var sequence_name: String
