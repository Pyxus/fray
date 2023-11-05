class_name FrayAnimatorTrackerAnimationPlayer
extends FrayAnimatorTracker

@export var anim_player: AnimationPlayer


func _get_animation_list_impl() -> Array[String]:
	return anim_player.get_animation_list()


func _process_impl(delta: float) -> void:
	if anim_player.is_playing():
		if anim_player.current_animation_position == 0:
			emit_anim_started(anim_player.current_animation)

		emit_anim_updated(anim_player.current_animation, anim_player.current_animation_position)

		if anim_player.current_animation_position + delta >= anim_player.current_animation_length:
			emit_anim_finished(anim_player.current_animation)
