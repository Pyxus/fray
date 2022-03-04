extends AnimationPlayer

const Util = preload("res://addons/stray_combat_framework/lib/utils/util.gd")
const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const CombatFSM = preload("../state_management/combat_fsm.gd")
const Condition = preload("../state_management/conditions/condition.gd")
const StringCondition = preload("../state_management/conditions/string_condition.gd")
const CombatTree = preload("../state_management/combat_tree.gd")
const CombatState = preload("../state_management/combat_state.gd")

const CombatAnimation = preload("combat_animation.gd")
const AnimationTransition = preload("animation_transition.gd")
const AnimationState = preload("animation_state.gd")

export var combat_fsm: NodePath setget set_combat_fsm
export var input_detector: NodePath setget set_input_detector

var _combat_fsm: CombatFSM
var _input_detector: InputDetector
var _anim_by_state: Dictionary
var _anim_by_state_transition: Dictionary
var _anim_by_combat_tree_transition: Dictionary
var _current_combat_animation: CombatAnimation
var _next_combat_animation: CombatAnimation
var _current_animation_state: AnimationState
var _next_animation_state: AnimationState


func _ready() -> void:
	_combat_fsm = get_node_or_null(combat_fsm)
	_input_detector = get_node_or_null(input_detector)
	set_combat_fsm(combat_fsm)
	set_input_detector(input_detector)

	connect("animation_finished", self, "_on_animation_finished")


func _process(delta: float) -> void:
	if _current_combat_animation != null:
		var next_anim_transition: AnimationTransition = _current_animation_state.get_next_transition(_combat_fsm._condition_by_name)
		if next_anim_transition != null:
			match next_anim_transition.switch_mode:
				AnimationTransition.SwitchMode.IMMEDIATE:
					_current_animation_state = next_anim_transition.to
					play(_current_animation_state.animation)
				AnimationTransition.SwitchMode.SYNCHRONIZED:
					#TODO: Sychronized is identical to immediate at the moment
					_current_animation_state = next_anim_transition.to
					play(_current_animation_state.animation)
				AnimationTransition.SwitchMode.END:
					_next_animation_state = next_anim_transition.to
		else:
			var condition: Condition = _current_animation_state.active_condition
			if condition is StringCondition and _current_animation_state != _current_combat_animation.root:
				if _combat_fsm._condition_by_name.has(condition.condition_name) and !_combat_fsm._condition_by_name[condition.condition_name]:
					if _next_combat_animation != null and _current_combat_animation != _next_combat_animation:
						_current_combat_animation = _next_combat_animation
						_current_animation_state = _current_animation_state.root
						_next_combat_animation = null
						play(_current_animation_state.animation)
					elif _current_animation_state != _current_combat_animation.root: 
						_current_animation_state = _current_combat_animation.root
						play(_current_animation_state.animation)
		

		
		
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
	if _next_animation_state != null:
		_current_animation_state = _next_animation_state
		_next_animation_state = null
		play(_current_animation_state.animation)
	elif _next_combat_animation != null:
		_current_combat_animation = _next_combat_animation
		_current_animation_state = _current_combat_animation.root
		_next_combat_animation = null
		play(_current_animation_state.animation)
	elif not _combat_fsm.is_current_state_root():
		_combat_fsm.revert_to_root()


func _on_CombatFSM_state_changed(from: CombatState, to: CombatState) -> void:
	var transition_anim: CombatAnimation = get_state_transition_animation(from, to)
	_play_combat_animation(to, transition_anim)
		

func _on_CombatFSM_tree_changed(from: CombatTree, to: CombatTree) -> void:
	var transition_anim: CombatAnimation = get_tree_transition_animation(from, to)
	_play_combat_animation(to.get_root(), transition_anim)


func _play_combat_animation(combat_state: CombatState, transition_anim: CombatAnimation = null) -> void:
	if transition_anim != null:
		_current_combat_animation = transition_anim
		_current_animation_state = transition_anim.root
		_next_combat_animation = get_state_animation(combat_state)
		play(_current_animation_state.animation)
	else:
		_current_combat_animation = get_state_animation(combat_state)
		_current_animation_state = _current_combat_animation.root
		play(_current_animation_state.animation)
		
# TODO: Move autobuffering to CombatFSM 
# The AnimationPlayer should not be responsible for buffering inputs for the state machine
func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	_combat_fsm.buffer_input(detected_input)


class QueuedAnimation:
	extends Reference
