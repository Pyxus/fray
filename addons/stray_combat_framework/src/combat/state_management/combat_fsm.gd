extends Node


signal situation_changed(from, to)
signal state_changed(from, to) 

enum FrameData {
	NEUTRAL,
	START_UP,
	ACTIVE,
	ACTIVE_GAP,
	RECOVERY,
}

const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")

const Situation = preload("situation.gd")
const CombatState = preload("combat_state.gd")

export(FrameData) var frame_data: int
export var input_buffer_max_size: int = 2
export var input_max_time_in_buffer: float = 0.3

var condition_by_name: Dictionary

var _input_buffer: Array
var _situations: Array
var _current_situation: Situation
var _current_state: CombatState
var _condition_by_name: Dictionary
var _my_states: Array


func _ready() -> void:
	var state = _current_situation.get_root()


func _process(delta: float) -> void:
	if _current_situation != null:
		var next_transition := _current_situation.get_next_transition()
		if next_transition != null:
			var prev_situation: Situation = _current_situation
			set_situation(next_transition.to)
			emit_signal("situation_changed", prev_situation, _current_situation)

		if not _input_buffer.empty():
			if frame_data == FrameData.RECOVERY or frame_data == FrameData.NEUTRAL:
				var buffered_detected_input: BufferedDetectedInput = _input_buffer.front()
				var next_state = _current_state.get_next_chain(buffered_detected_input.detected_input)

				if next_state != null:
					var prev_state: CombatState = _current_state
					_current_state = next_state
					_input_buffer.pop_front()
					emit_signal("state_changed", prev_state, _current_state)


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


func add_situation(situation: Situation) -> void:
	if _situations.has(situation):
		push_warning("Situation has already been added to tree.")
		return
	
	situation.condition_by_name = _condition_by_name
	_situations.append(situation)


func set_situation(situation: Situation) -> void:
	if not _situations.has(situation):
		push_warning("The given situation does not exist within tree.")
		return
	
	_current_situation = situation
	_current_state = situation.get_root()
	

class BufferedDetectedInput:
	extends Reference

	const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

	var detected_input: DetectedInput
	var time_in_buffer: float
