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
var _state_anim_queue: Array
var _transition_anim_queue: Array
var _next_animation: String
var _is_playing_transition_anim: bool
var _prev_root_anim_queue_hash: int


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
		var anim_queue := _get_animation_queue(combat_anim)
		var queue_hash := anim_queue.hash()
		
		if anim_queue.hash() != _prev_root_anim_queue_hash:
			_prev_root_anim_queue_hash = queue_hash
			_state_anim_queue += anim_queue
			_play_next_state_animation()
		
		
func associate_state_with_animation(state: CombatState, combat_animation: CombatAnimation) -> void:
	_anim_by_state[state] = combat_animation


func get_state_animation(state: CombatState) -> CombatAnimation:
	if _anim_by_state.has(state):
		return _anim_by_state[state]
	return null


func get_state_transition_animation(from: CombatState, to: CombatState) -> CombatAnimation:
	var state_transition_tuple := [from, to]
	if _anim_by_state_transition.has(state_transition_tuple):
		return _anim_by_state_transition[state_transition_tuple]
	return null


func get_tree_transition_animation(from: CombatTree, to: CombatTree) -> CombatAnimation:
	var state_transition_tuple := [from, to]
	if _anim_by_combat_tree_transition.has(state_transition_tuple):
		return _anim_by_combat_tree_transition[state_transition_tuple]
	return null


func associate_state_transition_with_animation(from: CombatState, to: CombatState, combat_animation: CombatAnimation) -> void:
	var transition_tuple := [from, to]
	_anim_by_state_transition[transition_tuple] = combat_animation


func associate_tree_transition_with_animation(from: CombatTree, to: CombatTree, combat_animation: CombatAnimation) -> void:
	var transition_tuple := [from, to]
	_anim_by_combat_tree_transition[transition_tuple] = combat_animation


func _get_animation_queue(combat_animation: CombatAnimation) -> Array:
	for conditional_anim in combat_animation.conditional_animations:
		if _combat_fsm.is_condition_true(conditional_anim.condition):
			return conditional_anim.animation_queue
			
	return combat_animation.default_animation_queue


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


func _play_next_transition_animation() -> void:
	var next_anim: String = _transition_anim_queue.pop_front()
	if not has_animation(next_anim):
		push_error("Failed to play transition animation. No animation in CombatAnimationPlayer named '%s'." % next_anim)
		_combat_fsm.revert_to_root()
		return
	
	var animation := get_animation(next_anim)
	if animation.loop:
		push_warning("Animatnion '%s' is set to loop. Transition will never end." % next_anim)

	play(next_anim)


func _play_next_state_animation() -> void:
	var next_anim: String = _state_anim_queue.pop_front()
	if not has_animation(next_anim):
		push_error("Failed to play state animation. No animation in CombatAnimationPlayer named '%s'." % next_anim)

	var animation := get_animation(next_anim)
	if animation.loop:
		if not _state_anim_queue.empty():
			push_warning("Animation '%s' is set to loop but another animation exist witin the state animation queue. The next animation will not play." % next_anim)
	
		if not _combat_fsm.is_current_state_root():
			push_warning("Animation '%s' is set to loop in a non-root state. This state can not automatically revert to root." % next_anim)

	play(next_anim)


func _determine_next_animation_play(to: CombatState, transition_anim: CombatAnimation) -> void:
	_transition_anim_queue.clear()
	_state_anim_queue.clear()

	if transition_anim != null:
		_transition_anim_queue += _get_animation_queue(transition_anim)

	if not _transition_anim_queue.empty():
		_play_next_transition_animation()
	else:
		var to_state_anim := get_state_animation(to)
		if to_state_anim == null:
			push_error("State changed but no animation associated with new state '%s'. Reverting to root" % to)
			_combat_fsm.revert_to_root()
			return
		
		_state_anim_queue += _get_animation_queue(to_state_anim)
		_play_next_state_animation()


func _on_animation_finished(animation: String) -> void:
	if not _transition_anim_queue.empty():
		_play_next_transition_animation()
	elif not _state_anim_queue.empty():
		_play_next_state_animation()
	elif not _combat_fsm.is_current_state_root():
		var current_state := _combat_fsm.get_current_state()
		var current_animation = get_state_animation(current_state)
		if not current_animation.has_animation(animation):
			push_warning("Recently finished animation '%s' is not associated with the current combat state '%s'. Animation may have been played externally." % [animation, current_state])

		_combat_fsm.revert_to_root()
		_prev_root_anim_queue_hash = -1


func _on_CombatFSM_state_changed(from: CombatState, to: CombatState) -> void:
	var transition_anim: CombatAnimation = get_state_transition_animation(from, to)
	_determine_next_animation_play(to, transition_anim)
		

func _on_CombatFSM_tree_changed(from: CombatTree, to: CombatTree) -> void:
	var transition_anim: CombatAnimation = get_tree_transition_animation(from, to)
	_determine_next_animation_play(to.get_root(), transition_anim)


# TODO: The AnimationPlayer should not be responsible for buffering inputs for the state machine
func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	_combat_fsm.buffer_input(detected_input)


class QueuedAnimation:
	extends Reference
