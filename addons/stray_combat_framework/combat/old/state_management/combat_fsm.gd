## docstring
extends Node
## docstring

#signals

enum FrameState {
	IDLE,
	STARTUP,
	ACTIVE,
	ACTIVE_GAP,
	RECOVERY,
}

const DetectedInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_input.gd")
const InputData = preload("input_data/input_data.gd")
const VirtualInputData = preload("input_data/virtual_input_data.gd")
const SequenceInputData = preload("input_data/sequence_input_data.gd")
const FighterState = preload("states/fighter_state.gd")
const RootIdleState = preload("states/root_idle_state.gd")
const IdleState = preload("states/idle_state.gd")
const ActionState = preload("states/action_state.gd")

#exported variables

export var anim_player: NodePath
export(FrameState) var frame_state: int
export var input_bufer_size: int = 2
export var input_buffer_duration: float = 0.3


var _root_by_situation: Dictionary
var _current_situation: String
var _current_fighter_state: FighterState
var _previous_fighter_state: FighterState
var _input_buffer: Array
var _time_since_first_input: float
var _anim_player: AnimationPlayer

#onready variables

#optional built-in virtual _init method


func _ready() -> void:
	_anim_player = get_node(anim_player) as AnimationPlayer
	_anim_player.connect("animation_finished", self, "_on_AnimPlayer_animation_finished")


func _process(delta: float) -> void:
	if not _input_buffer.empty():
		if frame_state == FrameState.RECOVERY or frame_state == FrameState.IDLE:
			advance(_input_buffer.pop_front().detected_input)

		for buffered_detected_input in _input_buffer:
			if buffered_detected_input.time_in_buffer >= input_buffer_duration:
				_input_buffer.erase(buffered_detected_input)
			buffered_detected_input.time_in_buffer += delta


func buffer_input(detected_input: DetectedInput) -> void:
	var current_buffer_size: int = _input_buffer.size()
	var buffered_detected_input := BufferedDetectedInput.new()

	buffered_detected_input.detected_input = detected_input

	if current_buffer_size + 1 > input_bufer_size:
		_input_buffer[current_buffer_size - 1] = buffered_detected_input
	else:
		_input_buffer.append(buffered_detected_input)



func advance(detected_input: DetectedInput) -> void:
	if _anim_player == null:
		push_error("Failed to advance. AnimationPlayer is not set.")
		return

	if _current_fighter_state == null or _current_situation.empty():
		push_warning("Failed to advance state. Situation may not be set.")
		return

	var next_state := _current_fighter_state.get_next_action(detected_input)
	if next_state != null:
		switch_to_state(next_state)


func create_situation(situation: String) -> RootIdleState:
	var root := RootIdleState.new()
	if _root_by_situation.has(situation):
		push_warning("Sitatuon '%s' already exists" % situation)
		return null
	_root_by_situation[situation] = root
	return root


func create_action_si(animation: String, sequence: String) -> ActionState:
	var action_state := ActionState.new()
	var input_data := SequenceInputData.new()

	input_data.name = sequence
	action_state.animation = animation
	action_state.input = input_data
	return action_state


func create_action_vi(animation: String, input_id: int, is_activated_on_release: bool = false) -> ActionState:
	var action_state := ActionState.new()
	var input_data := VirtualInputData.new()

	input_data.id = input_id
	action_state.animation = animation
	action_state.input = input_data

	return action_state


func remove_situation(situation: String) -> void:
	if _root_by_situation.has(situation):
		_root_by_situation.erase(situation)


func switch_to_state(fighter_state: FighterState) -> void:
	var situation: String = get_situation_with_state(fighter_state)
	var situation_root: RootIdleState = get_situation_root(situation)
	
	if situation_root == null:
		if fighter_state is RootIdleState:
			push_error("Failed to switch to state '%s'. No situation with RootIdleState '%s' exists in CombatFSM." % [fighter_state, fighter_state])
		else:
			push_error("Failed to switch to state '%s'. Fighter state does not belong to any situation in CombatFSM." % fighter_state)
		return

	_current_situation = situation
	_set_current_fighter_state(fighter_state)
	_play_animation(fighter_state.animation)


func get_situation_root(situation: String) -> RootIdleState:
	if _root_by_situation.has(situation):
		return _root_by_situation[situation]
	return null


func get_situation_with_state(fighter_state: FighterState) -> String:
	for situation in _root_by_situation:
		var fighter_root := fighter_state if fighter_state is RootIdleState else fighter_state.get_root()
		var situation_root: RootIdleState = _root_by_situation[situation]

		if situation_root == fighter_root:
			return situation
	return ""


func set_current_situation(situation: String) -> void:
	if not _root_by_situation.has(situation):
		push_error("Failed to set situation. Situation '%s' does not exist." % situation)
		return

	_current_situation = situation
	switch_to_state(get_situation_root(_current_situation))


func _play_animation(animation: String) -> void:
	if _anim_player == null:
		push_error("Failed to play animation. AnimationPlayer is not set.")
		return

	if not _anim_player.has_animation(animation):
		push_error("AnimationPlayer does not have animation named '%s'" % animation)
		return
	
	_anim_player.play(animation)
	

func _set_current_fighter_state(fighter_state: FighterState) -> void:
	_previous_fighter_state = _current_fighter_state
	_current_fighter_state = fighter_state


func _revert_to_root_state() -> void:
	switch_to_state(get_situation_root(_current_situation))


func _on_AnimPlayer_animation_finished(anim_name: String) -> void:
	if _current_fighter_state is ActionState and _current_fighter_state.animation == anim_name:
		_revert_to_root_state()


class BufferedDetectedInput:
	extends Reference

	const DetectedInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_input.gd")

	var detected_input: DetectedInput
	var time_in_buffer: float
