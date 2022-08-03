extends Node
## A node that navigates between states in a CombatSituation based on buffered inputs.
##
## @desc:
##		The graph is able to buffer a combatant's next action 
##		for a smoother player experience.

const CircularBuffer = preload("res://addons/fray/lib/data_structures/circular_buffer.gd")
const BufferedInput = preload("buffered_input/buffered_input.gd")
const BufferedInputButton = preload("buffered_input/buffered_input_button.gd")
const BufferedInputSequence = preload("buffered_input/buffered_input_sequence.gd")
const CombatSituation = preload("combat_situation.gd")
const CombatGraphData = preload("combat_graph_data.gd")

enum ProcessMode {
	IDLE,
	PHYSICS,
	MANUAL,
}

signal state_changed(situation, from, to)

## If true the combat graph will be processing.
export var active: bool

## Allow transitions transitions to occur in the graph.
## Enabling and disabling this property allows you to control when a combatant
## is allowed to transition into the next buffered state.
## This can be used to control when a player is allowed to 'cancel' an attack.
export var allow_transitions: bool

## The max number of detected inputs that can be buffered.
export var input_buffer_capacity: int = 20

## The max time a detected input can exist in the buffer before it is ignored.
export var input_max_time_in_buffer: float = 0.1

## The process mode of this graph.
export(ProcessMode) var process_mode: int = ProcessMode.PHYSICS setget set_process_mode

## Collection of named combat situations known to graph
var graph_data: CombatGraphData setget set_graph_data

## The current CombatSituation used by this graph.
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
	
	set_process_mode(process_mode)


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
	
	if _current_situation.empty():
		push_warning("Failed to advance, no situation set.")
		return
	
	var situation: CombatSituation = graph_data.get_situation(_current_situation)
	var current_time := OS.get_ticks_msec()
	
	if allow_transitions:
		for buffered_input in _input_buffer:
			var next_state: String = situation.get_next_state(buffered_input)
			var time_since_inputted: int = current_time - buffered_input.time_stamp
			
			if not next_state.empty() and time_since_inputted <= input_max_time_in_buffer * 1000:
				_buffered_state = next_state
				break

		if  not _buffered_state.empty():
			var previous_state: String = situation.current_state
			situation.advance_to(_buffered_state)
			situation.time_since_last_input = current_time / 1000.0
			_buffered_state = ""

## Returns the current state machine to it's initial state if available
func goto_initial_state(ignore_buffer: bool = false) -> void:
	if _current_situation.empty() or not ignore_buffer and not _buffered_state.empty():
		return

	var situation: CombatSituation = graph_data.get_situation(_current_situation)
	if situation.initial_state.empty():
		push_warning("Failed to to go to initial combat state. Current situation '%s' does not have an initial state set." % situation)
		return
	
	situation.advance_to(situation.initial_state)

## Buffers an input button to be processed by the graph
func buffer_button(input: String, is_released: bool = false) -> void:
	_input_buffer.add(BufferedInputButton.new(OS.get_ticks_msec(), input, is_released))

## Buffers an input sequence to be processed by the graph
func buffer_sequence(sequence_name: String) -> void:
	_input_buffer.add(BufferedInputSequence.new(OS.get_ticks_msec(), sequence_name))

## Clears the current buffered inputs and buffered state
func clear_buffer() -> void:
	_buffered_state = ""
	_input_buffer.clear()

func change_situation(situation: String) -> void:
	if not is_instance_valid(graph_data):
		push_error("Failed to change situation. Graph data is not set.")
		return

	if not graph_data.has_situation(situation):
		push_error("Failed to change situation. Graph data does not contain situation named '%s'." % situation) 
		return

	if situation != _current_situation:
		_current_situation = situation
		graph_data.get_situation(situation).initialize()


func get_current_situation() -> String:
	return _current_situation


func get_current_state() -> String:
	if not is_instance_valid(graph_data):
		return ""
	
	return graph_data.get_situation(_current_situation).current_state
##
func set_graph_data(new_graph_data: CombatGraphData) -> void:
	graph_data = new_graph_data

	for situation in graph_data.get_all_situations():
		situation.connect("state_changed", self, "_on_Situation_state_changed")

	_current_situation = ""
	_update_evaluator_functions()


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

	for situation in graph_data.get_all_situations():
		var evaluation_func: FuncRef = _external_condition_evaluator if _external_condition_evaluator != null else funcref(self, "is_condition_true")
		situation.set_condition_evaluator(evaluation_func)


func _on_Situation_state_changed(from: String, to: String) -> void:
	emit_signal("state_changed", _current_situation, from, to)