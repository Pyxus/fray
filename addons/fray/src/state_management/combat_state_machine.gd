extends Node
## A node that navigates between states in a CombatSituation based on buffered inputs.
##
## @desc:
##		The state machine is able to buffer a combatant's next action 
##		for a smoother player experience.

const CircularBuffer = preload("res://addons/fray/lib/data_structures/circular_buffer.gd")
const BufferedInput = preload("buffered_input/buffered_input.gd")
const BufferedInputButton = preload("buffered_input/buffered_input_button.gd")
const BufferedInputSequence = preload("buffered_input/buffered_input_sequence.gd")
const CombatSituation = preload("combat_situation.gd")

signal situation_changed(from, to)

enum ProcessMode {
	IDLE,
	PHYSICS,
	MANUAL,
}


## If true the combat state machine will be processing.
export var active: bool

## Allow transitions transitions to occur in the state machine.
## Enabling and disabling this property allows you to control when a combatant
## is allowed to transition into the next buffered state.
## This can be used to control when a player is allowed to 'cancel' an attack.
export var allow_transitions: bool

## The max number of detected inputs that can be buffered.
export var input_buffer_capacity: int = 20

## The max time a detected input can exist in the buffer before it is ignored.
export var input_max_time_in_buffer: float = 0.1

## The process mode of this state machine.
export(ProcessMode) var process_mode: int = ProcessMode.PHYSICS

## Type: Dictionary<String, CombatSituation>
var _situation_by_name: Dictionary

## The current CombatSituation used by this state machine.
var _current_situation: String

## Type: Dictionary<String, bool>
var _conditions: Dictionary

## Type: CircularBuffer<BufferedInput>
var _input_buffer := CircularBuffer.new()

## Type: func(String) -> bool
var _external_condition_evaluator: FuncRef

var _buffered_state: String


func _ready() -> void:
	if Engine.editor_hint:
		return

	_input_buffer.capacity = input_buffer_capacity
	_update_evaluator_functions()


func _process(delta: float) -> void:
	if Engine.editor_hint:
		return

	var current_situation := get_current_situation()
	if current_situation != null:
		current_situation.update(delta)

	if process_mode == ProcessMode.IDLE:
		advance(delta)
		

func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return

	var current_situation := get_current_situation()
	if current_situation != null:
		current_situation.physics_update(delta)

	if process_mode == ProcessMode.PHYSICS:
		advance(delta)

## Adds a combat situation to the state machine.
func add_situation(name: String, situation: CombatSituation) -> void:
	if has_situation(name):
		push_warning("Combat situation named '%s' already exists. Previous instance will be overwritten." % name)

	_situation_by_name[name] = situation

## Returns a situation with the given name if it exists.
func get_situation(name: String) -> CombatSituation:
	if has_situation(name):
		return _situation_by_name[name]
	return null

## Returns true if a situation with the given name exists
func has_situation(name: String) -> bool:
	return _situation_by_name.has(name)

## Manually advances the the combat state machine's processing.
func advance(delta: float) -> void:
	if not active:
		return
	
	if _current_situation.empty():
		push_warning("Failed to advance, no situation set.")
		return
	
	var situation: CombatSituation = get_situation(_current_situation)
	var current_time := OS.get_ticks_msec()
	
	if allow_transitions:
		for buffered_input in _input_buffer:
			var next_state: String = situation.get_next_state(buffered_input)
			var time_since_inputted: int = current_time - buffered_input.time_stamp
			
			if not next_state.empty() and time_since_inputted <= input_max_time_in_buffer * 1000:
				_buffered_state = next_state
				break

		if  not _buffered_state.empty():
			situation.go_to(_buffered_state)
			situation.time_since_last_input = current_time / 1000.0
			_buffered_state = ""

## Returns the current state machine to it's initial state if available
func goto_initial_state(ignore_buffer: bool = false) -> void:
	if _current_situation.empty() or not ignore_buffer and not _buffered_state.empty():
		return

	var situation: CombatSituation = get_situation(_current_situation)
	if situation.initial_state.empty():
		push_warning("Failed to to go to initial combat state. Current situation '%s' does not have an initial state set." % situation)
		return
	
	situation.go_to(situation.initial_state)

## Buffers an input button to be processed by the state machine
func buffer_button(input: String, is_released: bool = false) -> void:
	_input_buffer.add(BufferedInputButton.new(OS.get_ticks_msec(), input, is_released))

## Buffers an input sequence to be processed by the state machine
func buffer_sequence(sequence_name: String) -> void:
	_input_buffer.add(BufferedInputSequence.new(OS.get_ticks_msec(), sequence_name))

## Clears the current buffered inputs and buffered state
func clear_buffer() -> void:
	_buffered_state = ""
	_input_buffer.clear()

## Changes the currently activate situation
func change_situation(situation: String) -> void:
	if _situation_by_name.empty():
		push_error("Failed to change situation. State machine has no situations added.")
		return

	if not has_situation(situation):
		push_error("Failed to change situation. State machine does not contain situation named '%s'." % situation) 
		return

	if situation != _current_situation:
		var prev_situation := _current_situation
		var prev_sitch := get_situation(prev_situation)

		_current_situation = situation
		get_situation(situation).initialize()
		emit_signal("situation_changed", prev_situation, _current_situation)


func get_current_situation_name() -> String:
	return _current_situation


func get_current_situation() -> CombatSituation:
	return get_situation(_current_situation)


func get_current_state_name() -> String:
	if _situation_by_name.empty():
		return ""
	
	var current_situation := get_situation(_current_situation)

	return current_situation.get_current_state_name() if current_situation else null


## By default the ActionGraph uses an interal dictionary to keep track
## of conditions with set_condition(). However this can be overridden by
## providing an external condition evaluator function.
## The evaluation function should take a string as a method and return a bool.
func set_external_condition_evaluator(evaluation_func: FuncRef) -> void:
	_external_condition_evaluator = evaluation_func
	_update_evaluator_functions()


## Sets the value of a condition on the action state machine.
## Use for checking conditions such as prerequesites and advance condition.
func set_condition(condition: String, value: bool) -> void:
	_conditions[condition] = value

## Clears all conditions in internal conditional evaluator.
func clear_conditions() -> void:
	_conditions.clear()

## Returns the value of a condition if present in the internal condition evaluator.
func is_condition_true(condition: String) -> bool:
	if _conditions.has(condition):
		return _conditions[condition]
	
	push_warning("Combat condition '%s' was never set" % condition)
	return false


func _update_evaluator_functions() -> void:
	if _external_condition_evaluator != null and not _conditions.empty():
		push_warning("Combat state machine has internal conditions set but was given an external evaluator. Internal condition evaluation will not be used.")

	for situation in _situation_by_name.values():
		var evaluation_func: FuncRef =(
			_external_condition_evaluator if _external_condition_evaluator != null 
			else funcref(self, "is_condition_true"))
		situation.set_condition_evaluator(evaluation_func)
