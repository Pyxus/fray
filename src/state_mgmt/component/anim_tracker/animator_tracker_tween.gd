class_name FrayAnimatorTrackerTween
extends FrayAnimatorTracker
## [Tween] tracker

var _tween: Tween = null


func _get_animation_list_impl() -> PackedStringArray:
	return ["tween"]


func set_tween(tween: Tween) -> void:
	_tween = tween

	emit_anim_started("tween")
	tween.finished.connect(_on_Tween_finished)
	tween.step_finished.connect(_on_Tween_step_finished)


func _on_Tween_finished() -> void:
	emit_anim_finished("tween")


func _on_Tween_step_finished(idx: int) -> void:
	emit_anim_updated("tween", idx)
