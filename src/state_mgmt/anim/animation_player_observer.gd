class_name FrayAnimationPlayerObserver
extends FrayAnimationObserver

@export var anim_player: AnimationPlayer:
	set(value):
		anim_player = value

		_add_user_signals(anim_player.get_animation_list())

var _recent_animation: StringName = ""

#TODO: Just remember this doesn't currently account for animations playing backwards.
func _process(delta: float):
	if anim_player.is_playing():
		if anim_player.current_animation_position == 0:
			_emit_anim_started(anim_player.current_animation)
			_recent_animation = anim_player.current_animation
		
		_emit_anim_updated(anim_player.current_animation, anim_player.current_animation_position)
		
		if anim_player.current_animation_position + delta >= anim_player.current_animation_length:
			_emit_anim_finished(anim_player.current_animation)
	else:
		_recent_animation = ""