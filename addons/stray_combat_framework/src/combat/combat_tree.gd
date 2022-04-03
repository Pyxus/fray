extends Node
## docstring

signal situation_changed(from, to)
signal combat_state_changed(from, to)

enum ProcessMode {
	IDLE,
	PHYSICS,
	MANUAL,
}

#constants

const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const CircularBuffer = preload("res://addons/stray_combat_framework/lib/data_structures/circular_buffer.gd")

const CombatFSM = preload("state_management/combat_fsm.gd")
const CombatSituationFSM = preload("state_management/combat_situation_fsm.gd")

export var state_machine: Resource # CombatTreeFSM
export var input_detector: NodePath
export var active: bool
export var allow_combat_transitions: bool
export var input_buffer_capacity: int = 3
export var input_max_time_in_buffer: float = 0.1
export(ProcessMode) var process_mode: int setget set_process_mode

#public variables

onready var _input_detector: InputDetector = get_node_or_null(input_detector)

var _conditions: Dictionary # Dictionary<String, bool>
var _external_condition_evaluator: FuncRef
var _input_buffer := CircularBuffer.new() # CircularBuffer<BufferedInput>

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


func advance(delta: float) -> void:
	if state_machine == null:
		return

	var combat_fsm: CombatFSM = state_machine.get_combat_fsm() as CombatFSM

	if state_machine is CombatSituationFSM:
		var previous_situation_state: String = state_machine.current_state

		if state_machine.advance():
			combat_fsm = state_machine.get_combat_fsm() as CombatFSM

			if combat_fsm != null:
				combat_fsm.initialize()

			emit_signal("situation_state_changed", previous_situation_state, state_machine.current_state)
	
	if combat_fsm != null and active and not _input_buffer.empty():
		var inputs_to_erase: Array

		for buffered_input in _input_buffer:
			var next_state := combat_fsm.get_next_state(buffered_input.detected_input)

			if next_state.empty():
				inputs_to_erase.append(buffered_input)
			elif allow_combat_transitions:
				var previous_state: String = combat_fsm.current_state
				combat_fsm.advance_to(next_state)
				combat_fsm.time_since_last_input = OS.get_ticks_msec() / 1000.0
				inputs_to_erase.append(buffered_input)
				emit_signal("combat_state_changed", previous_state, combat_fsm.current_state)
			
			if buffered_input.time_in_buffer >= input_max_time_in_buffer:
				inputs_to_erase.append(buffered_input)
			else:
				buffered_input.time_in_buffer += delta
		
		for buffered_input in inputs_to_erase:
			_input_buffer.erase(buffered_input)


func goto_initial_combat_state() -> void:
	var combat_fsm: CombatFSM = state_machine.get_combat_fsm() as CombatFSM
	if combat_fsm == null:
		return

	if combat_fsm.initial_state.empty():
		push_warning("Failed to to go to initial combat state. Current CombatFSM '%s' does not have an initial state set." % combat_fsm)
		return

	var prev_state := combat_fsm.current_state
	combat_fsm.initialize()

	if prev_state != combat_fsm.current_state:
		emit_signal("combat_state_changed", prev_state, combat_fsm.current_state)


func buffer_input(detected_input: DetectedInput) -> void:
	var buffered_input := BufferedInput.new()
	var current_buffer_size: int = _input_buffer.size()

	buffered_input.detected_input = detected_input
	_input_buffer.append(buffered_input)


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
	var time_added: int


"""
class CircularBuffer:
	extends Reference

	const BufferedInput = preload("sequence/buffered_input.gd")

	var capacity: int = 1 setget set_capacity
	var count: int setget set_count, get_count

	var _read_index: int
	var _write_index: int
	var _buffer: Array

	func _init() -> void:
		for i in capacity:
			_buffer.append(null)


	func set_capacity(value: int) -> void:
		if value < 1:
			push_error("Circular buffer capacity can not be smaller than 1")

		capacity = max(1, value)
		_buffer.resize(value)
		_read_index = 0
		_write_index = 0


	func set_count(value) -> void:
		pass


	func get_count() -> int:
		return -1


	func add(buffered_input: BufferedInput) -> void:
		_buffer[_write_index % capacity] = buffered_input
		_write_index += 1


	func peek() -> BufferedInput:
		return _buffer[_read_index % capacity]


	func pop() -> BufferedInput:
		var buffered_input := peek()
		_read_index += 1
		return buffered_input
"""