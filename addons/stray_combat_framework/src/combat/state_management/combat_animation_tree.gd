extends "combat_fsm.gd"

const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")

const CombatAnimation = preload("combat_animation.gd")

export var anim_player: NodePath
export var input_detector: NodePath

var _anim_player: AnimationPlayer
var _input_detector: InputDetector
var _anim_by_state: Dictionary
var _anim_by_transition_data: Dictionary

func _ready() -> void:
    _anim_player = get_node_or_null(anim_player)
    _input_detector = get_node_or_null(input_detector)

    _anim_player.connect("animation_finished", self, "_on_AnimPlayer_animation_finished")
    _input_detector.connect("input_detected", self, "_on_InputDetector_input_detected")

    connect("situation_changed", self, "_on_situation_changed")

    revert_to_root()


func revert_to_root() -> void:
    .revert_to_root()

    var combat_anim := get_state_combat_animation(_current_state)
    if combat_anim != null:
        var anim := _get_animation_name(combat_anim)
        _anim_player.play(anim)


func set_state_combat_animation(state: CombatState, combat_animation: CombatAnimation) -> void:
    _anim_by_state[state] = combat_animation


func get_state_combat_animation(state: CombatState) -> CombatAnimation:
    if _anim_by_state.has(state):
        return _anim_by_state[state]
    return null


func set_transition_combat_animation(from: CombatState, to: CombatState, combat_animation: CombatAnimation) -> void:
    var transition_data := _get_transition_data(from, to)

    if transition_data == null:
        transition_data = TransitionData.new()
        transition_data.from = from
        transition_data.to = to
    
    _anim_by_transition_data[transition_data] = combat_animation


func _get_animation_name(combat_animation: CombatAnimation) -> String:
    for conditional_anim in combat_animation.conditional_animations:
        if is_condition_true(conditional_anim.condition):
            return conditional_anim.animation
            
    return combat_animation.default_animation


func _get_transition_data(from: CombatState, to: CombatState) -> TransitionData:
    for transition_data in _anim_by_transition_data:
        if transition_data.from == from and transition_data.to == to:
            return  transition_data
    return null


func _on_situation_changed(from: Situation, to: Situation) -> void:
    pass


func _on_state_chaged(from: CombatState, to: CombatState) -> void:
    pass

    
func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
    buffer_input(detected_input)


func _on_AnimPlayer_animation_finished(animation: String) -> void:
    pass


class TransitionData:
    extends Resource

    const CombatState = preload("combat_state.gd")

    var from: CombatState
    var to: CombatState