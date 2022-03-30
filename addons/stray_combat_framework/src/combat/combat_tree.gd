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

const CombatFSM = preload("state_management/combat_fsm.gd")

export var situation_fsm: Resource # SituationFSM
export var input_detector: NodePath
export var active: bool
export var allow_combat_transitions: bool
export var input_buffer_max_size: int = 3
export var input_max_time_in_buffer: float = 0.1
export(ProcessMode) var process_mode: int setget set_process_mode
export var use_external_condition_evaluator: bool

#public variables

onready var _input_detector: InputDetector = get_node_or_null(input_detector)

var _conditions: Dictionary # Dictionary<String, bool>
var _external_condition_evaluator: FuncRef
var _input_buffer: Array

#optional built-in virtual _init method

func _ready() -> void:
	if _input_detector != null:
		_input_detector.connect("input_detected", self, "_on_InputDetector_input_detected")

	if situation_fsm != null:
		situation_fsm.initialize()

	set_process_mode(process_mode)


func _process(delta: float) -> void:
	if process_mode == ProcessMode.IDLE:
		advance(delta)
		

func _physics_process(delta: float) -> void:
	if process_mode == ProcessMode.PHYSICS:
		advance(delta)


func advance(delta: float) -> void:
	if situation_fsm == null:
		return

	var combat_fsm := situation_fsm.get_current_state_obj() as CombatFSM
	var previous_situation_state: String = situation_fsm.current_state

	if situation_fsm.advance():
		combat_fsm = situation_fsm.get_current_state_obj() as CombatFSM

		if combat_fsm != null:
			combat_fsm.initialize()

		emit_signal("situation_state_changed", previous_situation_state, situation_fsm.current_state)

	if combat_fsm == null:
		return

	if active and not _input_buffer.empty():
		if allow_combat_transitions:
			var detected_input: DetectedInput = _input_buffer.front().detected_input
			var previous_state: String = combat_fsm.current_state

			if combat_fsm.advance(detected_input):
				combat_fsm.time_since_last_input = OS.get_ticks_msec() / 1000.0
				_input_buffer.pop_front()
				emit_signal("combat_state_changed", previous_state, combat_fsm.current_state)

		for buffered_input in _input_buffer:
			if buffered_input.time_in_buffer >= input_max_time_in_buffer:
				_input_buffer.erase(buffered_input)

			buffered_input.time_in_buffer += delta


func buffer_input(detected_input: DetectedInput) -> void:
	var buffered_detected_input := BufferedDetectedInput.new()
	var current_buffer_size: int = _input_buffer.size()
	
	buffered_detected_input.detected_input = detected_input
	
	if current_buffer_size + 1 > input_buffer_max_size:
		_input_buffer[current_buffer_size - 1] = buffered_detected_input
	else:
		_input_buffer.append(buffered_detected_input)


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


func set_condition(condition: String, value: bool) -> void:
	_conditions[condition] = value


func is_condition_true(condition: String) -> bool:
	if _conditions.has(condition):
		return _conditions[condition]
	
	push_warning("Combat condition '%s' was never set" % condition)
	return false

#private methods

func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	buffer_input(detected_input)


class BufferedDetectedInput:
	extends Reference

	const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

	var detected_input: DetectedInput
	var time_in_buffer: float