@tool

extends FrayAnimatorTracker
## EXPERIMENTAL [AnimationTree] tracker

@export_node_path("AnimationTree") var anim_tree_path: NodePath

var _anim_tree: AnimationTree = null
var _playback_state := _PlaybackState.new()


func _ready_impl() -> void:
	super()

	_anim_tree = fn_get_node_or_null.call(anim_tree_path)


func _process_impl(delta: float) -> void:
	if not _anim_tree.tree_root is AnimationNodeStateMachine:
		push_warning(
			"Due to interface limitations only the AnimationNodeStateMachine tree root is supported for tracking."
		)
		return

	var playback_path := "parameters/playback"
	var anim_node_path := ""
	var current_playback_state := _playback_state
	var current_playback = _anim_tree.get(playback_path)
	var current_node: StringName = current_playback.get_current_node()

	while current_playback != null:
		anim_node_path += "%s" % current_node

		if current_playback_state.current_node != current_node:
			if not current_playback_state.current_node.is_empty():
				emit_anim_finished(anim_node_path)

			current_playback_state.child = null
			current_playback_state.current_node = current_node

			emit_anim_started(anim_node_path)

		emit_anim_updated(anim_node_path, current_playback.current_play_position)

		playback_path += "/%s/playback" % current_node
		current_playback = _anim_tree.get(playback_path)

		if current_playback:
			anim_node_path += "/"
			current_playback_state.child = _PlaybackState.new()
			current_playback_state = current_playback_state.child
			current_node = current_playback.get_current_node()


func _get_animation_list_impl() -> PackedStringArray:
	var anim_player: AnimationPlayer = _anim_tree.get_node(_anim_tree.anim_player)
	return anim_player.get_animation_list()


func _get_configuration_warnings_impl() -> PackedStringArray:
	var anim_tree := fn_get_node_or_null.call(anim_tree_path)

	if anim_tree == null:
		return ["Path to animation tree not set."]

	if not anim_tree.tree_root is AnimationNodeStateMachine:
		return [
			"Due to interface limitations only the AnimationNodeStateMachine tree root is supported for tracking."
		]

	return []


class _PlaybackState:
	extends RefCounted

	var current_node: StringName = ""
	var child: _PlaybackState = null
