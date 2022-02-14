extends AnimationPlayer

const Util = preload("res://addons/stray_combat_framework/lib/util.gd")
const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const CombatFSM = preload("../state_management/combat_fsm.gd")
const Condition = preload("../state_management/conditions/condition.gd")
const StringCondition = preload("../state_management/conditions/string_condition.gd")
const CombatTree = preload("../state_management/combat_tree.gd")
const CombatState = preload("../state_management/combat_state.gd")

const CombatAnimation = preload("combat_animation.gd")

export var combat_fsm: NodePath setget set_combat_fsm
export var input_detector: NodePath setget set_input_detector

var _combat_fsm: CombatFSM
var _input_detector: InputDetector
var _anim_by_state: Dictionary
var _anim_by_state_transition: Dictionary
var _anim_by_combat_tree_transition: Dictionary
var _anim_queue: Array
var _next_animation: String
var _is_playing_transition_anim: bool


func _ready() -> void:
	_combat_fsm = get_node_or_null(combat_fsm)
	_input_detector = get_node_or_null(input_detector)
	set_combat_fsm(combat_fsm)
	set_input_detector(input_detector)

	connect("animation_finished", self, "_on_animation_finished")


func _process(delta: float) -> void:
	if _combat_fsm.active and _combat_fsm.is_current_state_root():
		var current_state = _combat_fsm.get_current_state()
		var combat_anim := get_state_animation(current_state)
		var combat_anim_name := _get_animation_name(combat_anim)
		
		if combat_anim_name != assigned_animation:
			play(combat_anim_name)


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
		if _combat_fsm.is_condition_true(conditional_anim.activation_condition):
			return conditional_anim.animation
			
	return combat_animation.default_animation


func set_combat_fsm(value: NodePath) -> void:
	combat_fsm = value

	if _combat_fsm != null:
		Util.safe_disconnect(_combat_fsm, "state_changed", self, "_on_CombatFSM_state_changed")
		Util.safe_disconnect(_combat_fsm, "tree_changed", self, "_on_CombatFSM_tree_changed")

		_combat_fsm = get_node_or_null(combat_fsm)

	if _combat_fsm != null:
		Util.safe_connect(_combat_fsm, "state_changed", self, "_on_CombatFSM_state_changed")
		Util.safe_connect(_combat_fsm, "tree_changed", self, "_on_CombatFSM_tree_changed")


func set_input_detector(value: NodePath) -> void:
	input_detector = value

	if _input_detector != null:
		Util.safe_disconnect(_input_detector, "input_detected", self, "_on_InputDetector_input_detected")

	_input_detector = get_node_or_null(input_detector)

	if _input_detector != null:
		Util.safe_connect(_input_detector, "input_detected", self, "_on_InputDetector_input_detected")


func _on_animation_finished(animation: String) -> void:
	if not _next_animation.empty():
		play(_next_animation)
		_next_animation = ""
	else:
		var current_state := _combat_fsm.get_current_state()
		var _current_animation = get_state_animation(current_state)
		if not _current_animation.has_animation(animation):
			push_warning("Recently finished animation '%s' is not associated with the current combat state '%s'. Animation may have been played externally." % [animation, current_state])
			
		_combat_fsm.revert_to_root()
			


func _on_CombatFSM_state_changed(from: CombatState, to: CombatState) -> void:
	_is_playing_transition_anim = false
	_next_animation = ""
	
	if from == to:
		return
	
	var transition_tuple := [from, to]
	if _anim_by_state_transition.has(transition_tuple):
		var transition_anim: CombatAnimation = _anim_by_state_transition[transition_tuple]
		var transition_anim_name := _get_animation_name(transition_anim)

		if not has_animation(transition_anim_name):
			push_error("Failed to play transition animation from combat state '%s' to combat state '%s'. No animation in player named '%s'." % [from, to, transition_anim_name])
		else:
			play(transition_anim_name)
			_is_playing_transition_anim = true

	var to_state_anim := get_state_animation(to)
	if to_state_anim == null:
		push_error("State changed but no animation associated with new state '%s'. Reverting to root" % to)
		_combat_fsm.revert_to_root()
		return
		
	var to_state_anim_name := _get_animation_name(to_state_anim)
	if not has_animation(to_state_anim_name):
		push_error("Failed to play current state animation. No animation in player named '%s'. Reverting to root" % to_state_anim_name)
		_combat_fsm.revert_to_root()
		return
	elif not _is_playing_transition_anim:
		play(to_state_anim_name)
	else:
		_next_animation = to_state_anim_name


func _on_CombatFSM_tree_changed(from: CombatTree, to: CombatTree) -> void:
	_is_playing_transition_anim = false
	_next_animation = ""
	
	if from == to:
		return
	
	var transition_tuple := [from, to]

	if _anim_by_combat_tree_transition.has(transition_tuple):
		var transition_anim: CombatAnimation = _anim_by_combat_tree_transition[transition_tuple]
		var transition_anim_name := _get_animation_name(transition_anim)

		if not has_animation(transition_anim_name):
			push_error("Failed to play transition animation from tree '%s' to  tree '%s'. No animation in player named '%s'." % [from, to, transition_anim_name])
		else:
			play(transition_anim_name)
			_is_playing_transition_anim = true
	
	var root_state_anim := get_state_animation(to.get_root())
	if root_state_anim == null:
		push_error("Tree changed but no animation associated with tree root state '%s'." % to.get_root())
		_combat_fsm.revert_to_root()
		return
		
	var root_state_anim_name := _get_animation_name(root_state_anim)
	if not has_animation(root_state_anim_name):
		push_error("Failed to play root state animation. No animation in player named '%s'." % root_state_anim_name)
		return
	elif not _is_playing_transition_anim:
		play(root_state_anim_name)
	else:
		_next_animation = root_state_anim_name


func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	_combat_fsm.buffer_input(detected_input)
