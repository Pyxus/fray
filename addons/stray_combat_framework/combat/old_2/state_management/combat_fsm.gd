extends Node

const Situation = preload("res://addons/stray_combat_framework/combat/old_2/state_management/situation.gd")

enum FrameState {
	IDLE,
	START_UP,
	ACTIVE,
	ACTIVE_GAP,
	RECOVERY,
}

export(FrameState) var frame_state: int
export var input_buffer_max_size: int = 2
export var input_max_time_in_buffer: float = 0.3
export var anim_player: NodePath

var _situation_by_name: Dictionary
var _current_situation: Situation
var _input_buffer: Array
var _anim_player: AnimationPlayer


func _ready() -> void:
	_anim_player = get_node(anim_player) as AnimationPlayer
	_anim_player.connect("animation_finished", self, "_on_AnimPlayer_animation_finished")

func _process(delta: float) -> void:
	if not _input_buffer.empty():
		if frame_state == FrameState.RECOVERY or frame_state == FrameState.IDLE:
			_advance(_input_buffer.pop_front().detected_input)
			pass

		for buffered_input in _input_buffer:
			if buffered_input.time_in_buffer >= input_max_time_in_buffer:
				_input_buffer.erase(buffered_input)
			buffered_input.time_in_buffer += delta

func create_situation(situation: String) -> void:
	pass

	
func buffer_input(input_id: int, is_pressed: bool = true) -> void:
	var input := BufferedVirtualInput.new()
	input.input_id = input_id
	input.is_pressed = is_pressed
	_input_buffer.append(input)


func buffer_input_sequence(sequence_name: String) -> void:
	var input := BufferedSequenceInput.new()
	input.sequence_name = sequence_name
	_input_buffer.append(input)


func _advance(buffered_input: BufferedInputFSM) -> void:
	pass


func _buffer_input(buffered_input: BufferedInputFSM) -> void:
	var current_buffer_size: int = _input_buffer.size()
	if current_buffer_size + 1 > input_buffer_max_size:
		_input_buffer[current_buffer_size - 1] = buffered_input
	else:
		_input_buffer.append(buffered_input)


func _on_AnimPlayer_animation_finished(animation: String) -> void:
	pass


class BufferedInputFSM:
	extends Reference

	var time_in_buffer: float

class BufferedVirtualInput:
	extends BufferedInputFSM

	var input_id: int
	var is_pressed: bool

class BufferedSequenceInput:
	extends BufferedInputFSM

	var sequence_name: String