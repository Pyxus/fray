@tool
class_name FrayAnimatorTrackerAnimatedSprite3D
extends FrayAnimatorTracker
## [AnimatedSprite3D] tracker

@export_node_path("AnimatedSprite3D") var anim_sprite_path: NodePath

var _anim_sprite: AnimatedSprite3D = null

var _prev_frame: int = -1


func _ready_impl() -> void:
	_anim_sprite = fn_get_node_or_null.call(anim_sprite_path)


func _process_impl(delta: float) -> void:
	if _anim_sprite.is_playing():
		if _anim_sprite.frame != _prev_frame:
			var last_frame := _anim_sprite.sprite_frames.get_frame_count(_anim_sprite.animation) - 1

			if _anim_sprite.frame == 0:
				emit_anim_started(_anim_sprite.animation)

			emit_anim_updated(_anim_sprite.animation, _anim_sprite.frame)

			if _anim_sprite.frame == last_frame:
				emit_anim_finished(_anim_sprite.animation)

		_prev_frame = _anim_sprite.frame


func _get_configuration_warnings_impl() -> PackedStringArray:
	var anim_sprite = fn_get_node_or_null.call(anim_sprite_path)

	if anim_sprite == null:
		return ["Path to animated sprite not set."]

	return []
