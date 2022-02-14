extends "combat_fsm.gd"

const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")

const CombatAnimation = preload("animation/combat_animation.gd")

export var anim_player: NodePath
export var input_detector: NodePath
export var enable_auto_revert: bool

var _anim_player: AnimationPlayer
var _input_detector: InputDetector
var _anim_by_state: Dictionary
var _anim_by_state_transition: Dictionary
var _anim_by_combat_tree_transition: Dictionary
var _anim_queue: Array
var _next_animation: String
var _is_playing_transition_anim: bool

func _ready() -> void:
	_anim_player = get_node_or_null(anim_player)
	_input_detector = get_node_or_null(input_detector)

	_anim_player.connect("animation_finished", self, "_on_AnimPlayer_animation_finished")
	_input_detector.connect("input_detected", self, "_on_InputDetector_input_detected")

	connect("tree_changed", self, "_on_tree_changed")
	connect("state_changed", self, "_on_state_changed")


func advance(delta: float) -> void:
	.advance(delta)
	
	if active:
		if is_current_state_root():
			var combat_anim := get_state_animation(_current_tree.get_root())
			var combat_anim_name := _get_animation_name(combat_anim)
			
			if combat_anim_name != _anim_player.assigned_animation:
				_anim_player.play(combat_anim_name)

		if _anim_player.is_playing():
			var is_anim_ending_next_frame := _anim_player.current_animation_position + delta >= _anim_player.current_animation_length
			if is_anim_ending_next_frame:
				call_deferred("_animation_reached_end", _anim_player.current_animation)
	

func associate_state_with_animation(state: CombatState, combat_animation: CombatAnimation) -> void:
	_anim_by_state[state] = combat_animation


func get_state_animation(state: CombatState) -> CombatAnimation:
	if _anim_by_state.has(state):
		return _anim_by_state[state]
	return null


func associate_state_transition_with_animation(from: CombatState, to: CombatState, combat_animation: CombatAnimation) -> void:
	var transition_tuple := [from, to]
	_anim_by_state_transition[transition_tuple] = combat_animation


func associate_tree_transition_with_animation(from: CombatTree, to: CombatTree, combat_animation: CombatAnimation) -> void:
	var transition_tuple := [from, to]
	_anim_by_combat_tree_transition[transition_tuple] = combat_animation


func _get_animation_name(combat_animation: CombatAnimation) -> String:
	for conditional_anim in combat_animation.conditional_animations:
		if is_condition_true(conditional_anim.activation_condition):
			return conditional_anim.animation
			
	return combat_animation.default_animation


func _animation_reached_end(animation: String) -> void:
	pass
	
	
func _on_tree_changed(from: CombatTree, to: CombatTree) -> void:
	_is_playing_transition_anim = false
	_next_animation = ""
	
	if from == to:
		return
	
	var transition_tuple := [from, to]

	if _anim_by_combat_tree_transition.has(transition_tuple):
		var transition_anim: CombatAnimation = _anim_by_combat_tree_transition[transition_tuple]
		var transition_anim_name := _get_animation_name(transition_anim)

		if not _anim_player.has_animation(transition_anim_name):
			push_error("Failed to play transition animation from tree '%s' to  tree '%s'. No animation in player named '%s'." % [from, to, transition_anim_name])
		else:
			_anim_player.play(transition_anim_name)
			_is_playing_transition_anim = true
	
	var root_state_anim := get_state_animation(to.get_root())
	if root_state_anim == null:
		push_error("Tree changed but no animation associated with tree root state '%s'." % to.get_root())
		revert_to_root()
		return
		
	var root_state_anim_name := _get_animation_name(root_state_anim)
	if not _anim_player.has_animation(root_state_anim_name):
		push_error("Failed to play root state animation. No animation in player named '%s'." % root_state_anim_name)
		return
	elif not _is_playing_transition_anim:
		_anim_player.play(root_state_anim_name)
	else:
		_next_animation = root_state_anim_name


func _on_state_changed(from: CombatState, to: CombatState) -> void:
	_is_playing_transition_anim = false
	_next_animation = ""
	
	if from == to:
		return
		
	var transition_tuple := [from, to]
	if _anim_by_state_transition.has(transition_tuple):
		var transition_anim: CombatAnimation = _anim_by_state_transition[transition_tuple]
		var transition_anim_name := _get_animation_name(transition_anim)

		if not _anim_player.has_animation(transition_anim_name):
			push_error("Failed to play transition animation from combat state '%s' to combat state '%s'. No animation in player named '%s'." % [from, to, transition_anim_name])
		else:
			_anim_player.play(transition_anim_name)
			_is_playing_transition_anim = true

	var to_state_anim := get_state_animation(to)
	if to_state_anim == null:
		push_error("State changed but no animation associated with new state '%s'. Reverting to root" % to)
		revert_to_root()
		return
		
	var to_state_anim_name := _get_animation_name(to_state_anim)
	if not _anim_player.has_animation(to_state_anim_name):
		push_error("Failed to play current state animation. No animation in player named '%s'. Reverting to root" % to_state_anim_name)
		revert_to_root()
		return
	elif not _is_playing_transition_anim:
		_anim_player.play(to_state_anim_name)
	else:
		_next_animation = to_state_anim_name


func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	buffer_input(detected_input)


func _on_AnimPlayer_animation_finished(animation: String) -> void:
	if not _next_animation.empty():
		_anim_player.play(_next_animation)
		_next_animation = ""
	else:
		var _current_animation = get_state_animation(_current_state)
		if not _current_animation.has_animation(animation):
			push_warning("Recently finished animation '%s' is not associated with the current combat state '%s'. Animation may have been played externally." % [animation, _current_state])
			
		revert_to_root()
