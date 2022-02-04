extends Node

const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")

const Situation = preload("situation.gd")

enum FrameData {
	NEUTRAL,
	START_UP,
	ACTIVE,
	ACTIVE_GAP,
	RECOVERY,
}

export(FrameData) var frame_data: int
export var input_buffer_max_size: int = 2
export var input_max_time_in_buffer: float = 0.3
export var anim_player: NodePath
export var input_detector: NodePath

var _anim_player: AnimationPlayer
var _input_detector: InputDetector
var _input_buffer: Array
var _current_situation: Situation


func _ready() -> void:
	_anim_player = get_node_or_null(anim_player)
	_input_detector = get_node_or_null(input_detector)


func _process(delta: float) -> void:
	pass


func buffer_input(detected_input: DetectedInput) -> void:
	var buffered_detected_input := BufferedDetectedInput.new()
	var current_buffer_size: int = _input_buffer.size()
	
	buffered_detected_input.detected_input = detected_input
	
	if current_buffer_size + 1 > input_buffer_max_size:
		_input_buffer[current_buffer_size - 1] = buffered_detected_input
	else:
		_input_buffer.append(buffered_detected_input)


class BufferedDetectedInput:
	extends Reference

	const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

	var detected_input: DetectedInput
	var time_in_buffer: float
