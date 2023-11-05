class_name FrayAnimatorTrackerAnimatedSprite3D
extends FrayAnimatorTracker

@export_node_path("AnimatedSprite3D") var anim_sprite_path: NodePath

@export var _anim_sprite: AnimatedSprite3D = null

var _prev_frame: int = -1


func _ready_impl() -> void:
	_anim_sprite = fn_get_node.call(anim_sprite_path)


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
