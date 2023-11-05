class_name FrayAnimatorTrackerAnimatedSprite3D
extends FrayAnimatorTracker

@export var anim_sprite: AnimatedSprite3D

var _prev_frame: int = -1


func _process_impl(delta: float) -> void:
	if anim_sprite.is_playing():
		if anim_sprite.frame != _prev_frame:
			var last_frame := anim_sprite.sprite_frames.get_frame_count(anim_sprite.animation) - 1

			if anim_sprite.frame == 0:
				emit_anim_started(anim_sprite.animation)

			emit_anim_updated(anim_sprite.animation, anim_sprite.frame)

			if anim_sprite.frame == last_frame:
				emit_anim_finished(anim_sprite.animation)

		_prev_frame = anim_sprite.frame
