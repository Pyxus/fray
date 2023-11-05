class_name FrayAnimatorTrackerAnimationTree
extends FrayAnimatorTracker
## EXPERIMENTAL [AnimationTree] tracker
##
## This tracker works by modifying the animations on the player used by the given tree.
## Specifically it adds a method call track which invoke the tracker's emit methods.

@export_node_path("AnimationTree") var anim_tree_path: NodePath

var _anim_tree: AnimationTree

func _ready_impl() -> void:
	super()
	
	_anim_tree = fn_get_node.call(anim_tree_path)

	var anim_player: AnimationPlayer = _anim_tree.get_node(_anim_tree.anim_player)
	var root_node: Node = anim_player.get_node(anim_player.root_node)

	for animation_name in anim_player.get_animation_list():
		var animation := anim_player.get_animation(animation_name)
		var track_idx := animation.add_track(Animation.TYPE_METHOD)

		print(fn_get_path_from.call(root_node))
		animation.track_set_path(track_idx, fn_get_path_from.call(root_node))

		if animation.length > 0.001 and animation.step > 0:
			var t := 0.0

			while t < animation.length:
				if t == 0:
					animation.track_insert_key(track_idx, t, {
						"args": [animation_name],
						"method": &"_emit_anim_started"
					})
				elif t + animation.step >= animation.length:
					animation.track_insert_key(track_idx, t, {
						"args": [animation_name],
						"method": &"_emit_anim_finished"
					})
				else:
					animation.track_insert_key(track_idx, t, {
						"args": [animation_name, t],
						"method": &"_emit_anim_updated"
					})

				t += animation.step 


func _get_animation_list_impl() -> PackedStringArray:
	var anim_player: AnimationPlayer = _anim_tree.get_node(_anim_tree.anim_player)
	return anim_player.get_animation_list()
