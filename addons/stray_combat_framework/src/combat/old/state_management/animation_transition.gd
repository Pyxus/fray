extends Resource

const AnimationState = preload("animation_state.gd")
const Condition = preload("conditions/condition.gd")

enum SwitchMode{
	IMMEDIATE,
	SYNCHRONIZED,
	END
}

var switch_mode: int
var advance_condition: Condition
var to: AnimationState setget set_to_state, get_to_state

var _to := WeakRef.new()


func set_to_state(state: AnimationState) -> void:
	_to = weakref(state)


func get_to_state() -> AnimationState:
	return _to.get_ref()
