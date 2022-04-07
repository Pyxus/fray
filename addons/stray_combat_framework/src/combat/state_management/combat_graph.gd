#TODO: See if buffer can be improved further.
	# Havn't looked into it but I think "garbage" inputs are clogging up the buffer.
	# If the buffer capacity is large enough it feels very smooth, but maybe it can be improved without need for a high capacity?

extends Node
## docstring

# Imports
const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const CircularBuffer = preload("res://addons/stray_combat_framework/lib/data_structures/circular_buffer.gd")
const ActionFSM = preload("action_fsm.gd")
const SituationFSM = preload("situation_fsm.gd")

enum ProcessMode {
	IDLE,
	PHYSICS,
	MANUAL,
}

#constants

## The state machine used by this CombatGraph.
export var state_machine: Resource # CombatFSM

## The path to the InputDetector used for detecting inputs.
## Inputs can optionally be fed directly with the buffer_input method.
export var input_detector: NodePath

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

## The process mode of this CombatGraph.
export(ProcessMode) var process_mode: int setget set_process_mode

#public variables

onready var _input_detector: InputDetector = get_node_or_null(input_detector)

var _conditions: Dictionary # Dictionary<String, bool>
var _external_condition_evaluator: FuncRef
var _input_buffer := CircularBuffer.new() # CircularBuffer<BufferedInput>
var _buffered_state: String

#optional built-in virtual _init method

func _ready() -> void:
	if _input_detector != null:
		_input_detector.connect("input_detected", self, "_on_InputDetector_input_detected")

	if state_machine != null:
		state_machine.initialize()

	_input_buffer.capacity = input_buffer_capacity
	set_process_mode(process_mode)
	_update_evaluator_functions()


func _process(delta: float) -> void:
	if process_mode == ProcessMode.IDLE:
		advance(delta)
		

func _physics_process(delta: float) -> void:
	if process_mode == ProcessMode.PHYSICS:
		advance(delta)

## Manually advances the the combat graph's processing.
func advance(delta: float) -> void:
	if not active:
		return

	if state_machine == null:
		return

	var action_fsm: ActionFSM = state_machine.get_action_fsm() as ActionFSM

	if state_machine is SituationFSM:
		var previous_situation_state: String = state_machine.current_state

		if state_machine.advance():
			var current_situation = state_machine.get_current_state_obj()
			action_fsm = current_situation.action_fsm as ActionFSM

			if action_fsm != null:
				action_fsm.initialize()
	
	if action_fsm != null:
		var current_time := OS.get_ticks_msec()

		if not _input_buffer.empty():
			for buffered_input in _input_buffer:
				var next_state := action_fsm.get_next_state(buffered_input.detected_input)

				if not next_state.empty() and (current_time - buffered_input.time_buffered) <= input_max_time_in_buffer * 1000:
					_buffered_state = next_state
					break

		if allow_action_transitions and not _buffered_state.empty():
			var previous_state: String = action_fsm.current_state
			action_fsm.advance_to(_buffered_state)
			action_fsm.time_since_last_input = current_time / 1000.0
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

## Buffers an input to be processed by the graph
func buffer_input(detected_input: DetectedInput) -> void:
	var buffered_input := BufferedInput.new()

	buffered_input.detected_input = detected_input
	buffered_input.time_buffered = OS.get_ticks_msec()
	_input_buffer.add(buffered_input)

## Clears the current buffered inputs and buffered state
func clear_buffer() -> void:
	_buffered_state = ""
	_input_buffer.clear()


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


func set_external_condition_evaluator(evaluation_func: FuncRef) -> void:
	_external_condition_evaluator = evaluation_func
	_update_evaluator_functions()


func set_condition(condition: String, value: bool) -> void:
	_conditions[condition] = value


func clear_conditions() -> void:
	_conditions.clear()

	
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


func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	buffer_input(detected_input)


class BufferedInput:
	extends Reference

	const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

	var detected_input: DetectedInput
	var time_in_buffer: float
	var time_buffered: int