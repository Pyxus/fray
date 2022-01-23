## docstring
extends Node
## docstring

#signals

enum FrameState {
	STARTUP,
	ACTIVE,
	ACTIVE_GAP,
	RECOVERY,
}

const DetectedInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_input.gd")
const FighterState = preload("fighter_state.gd")

const RootIdleState = preload("root_idle_state.gd")
const IdleState = preload("idle_state.gd")
const ActionState = preload("action_state.gd")

#exported variables

export(FrameState) var frame_state: int
export var input_bufer_size: int
export var input_buffer_duration: float = 0.5
export var anim_player: NodePath

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
		if frame_state == FrameState.RECOVERY:
			advance(_input_buffer.pop_front())

		if _time_since_first_input >= input_buffer_duration:
			_input_buffer.clear()

		_time_since_first_input += delta


func buffer_input(detected_input: DetectedInput) -> void:
	var current_buffer_size: int = _input_buffer.size()
	if current_buffer_size + 1 > input_bufer_size:
		_input_buffer[current_buffer_size - 1] = detected_input
	else:
		_input_buffer.append(detected_input)


func advance(detected_input: DetectedInput) -> void:
	if _anim_player == null:
		push_error("Failed to advance. AnimationPlayer is not set.")
		return

	if _current_fighter_state == null or _current_situation.empty():
		push_warning("Failed to advance state. Situation may not be set.")
		return

	var next_state := _current_fighter_state.get_next_action(detected_input)
	if next_state != null:
		if _current_fighter_state != null:
			pass


func create_situation(situation: String) -> RootIdleState:
	var root := RootIdleState.new()
	if _root_by_situation.has(situation):
		push_warning("Sitatuon '%s' already exists" % situation)
		return null
	_root_by_situation[situation] = root
	return root


func remove_situation(situation: String) -> void:
	if _root_by_situation.has(situation):
		_root_by_situation.erase(situation)


func get_situation_root(situation: String) -> RootIdleState:
	if _root_by_situation.has(situation):
		return _root_by_situation[situation]
	return null


func set_current_situation(situation: String) -> void:
	if not _root_by_situation.has(situation):
		push_error("Failed to set situation. Situation '%s' does not exist." % situation)
		return

	_current_situation = situation
	_set_current_fighter_state(_root_by_situation[situation])


func _set_current_fighter_state(fighter_state: FighterState) -> void:
	_previous_fighter_state = _current_fighter_state
	_current_fighter_state = fighter_state


func _revert_to_root_state() -> void:
	_set_current_fighter_state(get_situation_root(_current_situation))


func _is_previous_action_state_end_anim(anim_name: String) -> bool:
	if _previous_fighter_state != null:
		if _previous_fighter_state is ActionState:
			if _previous_fighter_state.animation == anim_name:
				return true
	return false


func _is_current_action_state_anim_ending(anim_name: String) -> bool:
	if _current_fighter_state is ActionState:
		if _current_fighter_state.animation == anim_name:
			return true
	return false


func _on_AnimPlayer_animation_finished(anim_name: String) -> void:
	if _current_fighter_state != null:
		if _current_fighter_state is ActionState:
			if _is_current_action_state_anim_ending(anim_name):
				_anim_player.play(_current_fighter_state.end_animation)
				_revert_to_root_state()
		elif _current_fighter_state is IdleState:
			if _is_previous_action_state_end_anim(anim_name):
				_anim_player.play(_current_fighter_state.animation)
	pass
