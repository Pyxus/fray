extends Resource

const AnimationState = preload("animation_state.gd")

var root: AnimationState

var _states: Array
var _associated_states: Array

func _init(default_anim: String = "") -> void:
	root = AnimationState.new()
	root.animation = default_anim
	root.combat_animation = self


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_associated_states.clear()


func associate_state(state: AnimationState) -> void:
	if not _associated_states.has(state):
		_associated_states.append(state)
		state.combat_animation = self