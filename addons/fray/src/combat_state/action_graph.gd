tool
extends Node
## A node that transitions between action states on a CombatFSM
##
## @desc:
##		The ActionGraph represents a fighter's current action and the actions available to them from that state through inputs.
##		The graph is also able to buffer a fighter's next action for a smoother player experience.
##		

# Imports
const CircularBuffer = preload("res://addons/fray/lib/data_structures/circular_buffer.gd")
const BufferedInput = preload("buffered_input/buffered_input.gd")
const BufferedInputButton = preload("buffered_input/buffered_input_button.gd")
const BufferedInputSequence = preload("buffered_input/buffered_input_sequence.gd")
const ActionFSM = preload("action_fsm.gd")

enum ProcessMode {
	IDLE,
	PHYSICS,
	MANUAL,
}

#constants

## The state machine used by this graph.
## The default implementations are ActionFSM and SituationFSM.
## The SituationFSM provides a way of grouping actions.
export var state_machine: Resource setget set_state_machine # ActionFSM

## If true the combat graph will be processing.
export var active: bool

## Allow transitions action transitions to occur in the graph.
## Enabling and disabling this property allows you to control when a fighter
## is able to transition into the next buffered state.
export var allow_action_transitions: bool

## The max number of detected inputs that can be buffered.
export var input_buffer_capacity: int = 10

## The max time a detected input can exist in the buffer before it is ignored.
export var input_max_time_in_buffer: float = 0.1

## The process mode of this graph.
export(ProcessMode) var process_mode: int setget set_process_mode

var _conditions: Dictionary # Dictionary<String, bool>
var _external_condition_evaluator: FuncRef
var _input_buffer := CircularBuffer.new() # CircularBuffer<BufferedInput>
var _buffered_state: String


func _ready() -> void:
	if Engine.editor_hint:
		return

	_input_buffer.capacity = input_buffer_capacity
	set_state_machine(state_machine)
	set_process_mode(process_mode)
	_update_evaluator_functions()


func _process(delta: float) -> void:
	if Engine.editor_hint:
		return

	if process_mode == ProcessMode.IDLE:
		advance(delta)
		

func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return

	if process_mode == ProcessMode.PHYSICS:
		advance(delta)

## Manually advances the the combat graph's processing.
func advance(delta: float) -> void:
	if not active:
		return

	if state_machine == null:
		push_warning("Failed to advance, no state machine set.")
		return

	if state_machine != null:
		var current_time := OS.get_ticks_msec()

		if not _input_buffer.empty():
			for buffered_input in _input_buffer:
				var next_state: String = state_machine.get_next_state(buffered_input)

				if not next_state.empty() and (current_time - buffered_input.time_stamp) <= input_max_time_in_buffer * 1000:
					_buffered_state = next_state
					break

		if allow_action_transitions and not _buffered_state.empty():
			var previous_state: String = state_machine.current_state
			state_machine.advance_to(_buffered_state)
			state_machine.time_since_last_input = current_time / 1000.0
			_buffered_state = ""

## Returns the current ActionFSM to it's initial state if available
func goto_initial_action_state(ignore_buffer: bool = false) -> void:
	if not ignore_buffer and not _buffered_state.empty():
		return

	var action_fsm: ActionFSM = state_machine.get_action_fsm() as ActionFSM
	if action_fsm == null:
		return

	if action_fsm.initial_state.empty():
		push_warning("Failed to to go to initial combat state. Current CombatFSM '%s' does not have an initial state set." % action_fsm)
		return

	var prev_state := action_fsm.current_state
	action_fsm.initialize()

## Buffers an input button to be processed by the graph
func buffer_input_button(id: int, is_released: bool = false) -> void:
	_input_buffer.add(BufferedInputButton.new(OS.get_ticks_msec(), id, is_released))

## Buffers an input sequence to be processed by the graph
func buffer_input_sequence(sequence_name: String) -> void:
	_input_buffer.add(BufferedInputSequence.new(OS.get_ticks_msec(), sequence_name))

## Clears the current buffered inputs and buffered state
func clear_buffer() -> void:
	_buffered_state = ""
	_input_buffer.clear()


func set_state_machine(value: ActionFSM) -> void:
	state_machine = value
	
	if state_machine != null:
		state_machine.initialize()
	
	
func set_process_mode(value: int) -> void:
	process_mode = value

	match process_mode:
		ProcessMode.IDLE:
			set_process(true)
			set_physics_process(false)
		ProcessMode.PHYSICS:
			set_process(false)
			set_physics_process(true)
		ProcessMode.MANUAL:
			set_process(false)
			set_physics_process(false)

## By default the ActionGraph uses an interal dictionary to keep track
## of conditions with set_condition(). However this can be overridden by
## providing an external condition evaluator function.
## The evaluation function should take a string as a method and return a bool.
func set_external_condition_evaluator(evaluation_func: FuncRef) -> void:
	_external_condition_evaluator = evaluation_func
	_update_evaluator_functions()


## Sets the value of a condition on the action graph.
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
		push_warning("Combat tree has internal conditions set but was given an external evaluator. Internal condition evaluation will not be used.")

	if state_machine != null:
		var evaluation_func: FuncRef = _external_condition_evaluator if _external_condition_evaluator != null else funcref(self, "is_condition_true")
		state_machine.set_condition_evaluator(evaluation_func)
