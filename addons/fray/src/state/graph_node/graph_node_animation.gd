extends "graph_node.gd"
## Animation state node
##
## @desc:
##		Used by `GraphNodeAnimationStateMachine` to update animation player

## Type: (String, bool, float) -> Void
var func_set_animation_state: FuncRef

var animation: String
var play_backwards: bool
var playback_speed: float = 1

func _enter_impl(args: Dictionary) -> void:
	if func_set_animation_state.is_valid():
		func_set_animation_state.call_func(animation, play_backwards, playback_speed)