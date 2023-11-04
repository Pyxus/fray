class_name FrayAnimationTreeObserver
extends FrayAnimationObserver

@export var anim_tree: AnimationTree:
	set(value):
		anim_tree = value

		if not is_inside_tree():
			return

		var anim_player: AnimationPlayer = anim_tree.get_node(anim_tree.anim_player)
		var root_node: Node = anim_player.get_node(anim_player.root_node)
		
		_add_user_signals(anim_player.get_animation_list())

		for animation_name in anim_player.get_animation_list():
			var animation := anim_player.get_animation(animation_name)
			var track_idx := animation.add_track(Animation.TYPE_METHOD)

			animation.track_set_path(track_idx, root_node.get_path_to(self))

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


func _ready() -> void:
	anim_tree = anim_tree
