extends "state_machine_builder.gd"
## Animation state machine builder


const GraphNodeAnimation = preload("../graph_node/graph_node_animation.gd")
const GraphNodeAnimationStateMachine = preload("../graph_node/graph_node_animation_state_machine.gd")

var animation_player: AnimationPlayer

func _build_impl(start_state: String) -> GraphNodeStateMachine:
	var root := GraphNodeAnimationStateMachine.new()
	root.animation_player = animation_player

	if animation_player == null:
		push_warning("Animation player never set in AnimationStateMachineBuilder. Consider using the `set_player` method.")

	_configure_state_machine(start_state, root)
	clear()
	return root


func _clear_impl() -> void:
	._clear_impl()
	_state_by_name.clear()
	_transitions.clear()
	animation_player = null

## Sets the animation player to be controlled by the state machine.
func set_player(anim_player: AnimationPlayer) -> Reference:
	animation_player = anim_player
	return self

## Adds a new animation state to the state machine.
##
## Returns a reference to this builder
func add_animation_state(name: String, animation: String, play_backwards := false, playback_speed := 1.0) -> Reference:
	var anim_node := GraphNodeAnimation.new()
	anim_node.animation = animation
	anim_node.play_backwards = play_backwards
	anim_node.playback_speed = playback_speed
	add_state(name, anim_node)
	return self