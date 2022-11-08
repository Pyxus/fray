extends "graph_node_state_machine.gd"
## Animation state machine
##
## @desc:
##		A simple animation state machine 
##		This is an alternative to Godot's `AnimationTree` but not a replacement.

const GraphNodeAnimation = preload("graph_node_animation.gd")
var GraphNodeAnimationStateMachine: GDScript = load("res://addons/fray/src/state/graph_node/graph_node_animation_state_machine.gd")

var animation_player: AnimationPlayer
var _animation_state: Dictionary

func _process_impl(_delta: float) -> void:
	var animation: String = _animation_state.get("animation", "")

	if animation_player == null:
		push_warning("Animation state machine does not have animation player")
		return

	if animation.empty():
		return
	
	if not animation_player.has_animation(animation):
		push_warning("Animation player does not have animation '%s'" % animation)
		return 

	animation_player.playback_speed = _animation_state.get("playback_speed", 1)

	if _animation_state.get("play_backwards", false):
		animation_player.play_backwards(animation)
	else:
		animation_player.play(animation)


func _on_node_added(name: String, node: Reference) -> void:
	._on_node_added(name, node)

	if node is GraphNodeAnimationStateMachine:
		node._animation_state = _animation_state
	elif node is GraphNodeAnimation:
		node.func_set_animation_state = funcref(self, "set_animation_state")


## Updates the state machine's animation state.
## Used internally by `GraphNodeAnimation`, user calls should be unecessary.
func set_animation_state(animation: String, play_backwards: bool, playback_speed: float) -> void:
	_animation_state["animation"] = animation
	_animation_state["play_backwards"] = play_backwards
	_animation_state["playback_speed"] = playback_speed
