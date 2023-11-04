class_name FrayAnimationObserver
extends Node

# Still experimenting so not going to bother with documentation yet.
# To use pick one of the observers (AnimationPlayer, or AnimationTree).
# Then have whoever is interested subscribe to an animation signal.
# Alternatively you have watch a specific animation using the on_XYZ methods.
# This has 0 assosiation to state manamgent at the moment.
# I just wanted to play around with how I could go about getting animation state.

# The tree observer just watches for a specific animation playing on the tree.
# In that way you can have a 'root' animation that you center everything else around.
# If your animations heavily depend on the tree but you still wish for the gameplay state to
# react to that 'root' animation.

signal animation_started(animation: StringName)
signal animation_finished(animation: StringName)
signal animation_updated(animation: StringName, play_position: float)


func on_start(animation: String, callable: Callable) -> void:
	connect(_get_user_signal_started(animation), callable)


func on_finished(animation: String, callable: Callable) -> void:
	connect(_get_user_signal_finished(animation), callable)


func on_update(animation: String, callable: Callable) -> void:
	connect(_get_user_signal_updated(animation), callable)


func _add_user_signals(animation_list: Array[String]) -> void:
	for anim_name in animation_list:
		add_user_signal(_get_user_signal_started(anim_name))
		add_user_signal(_get_user_signal_finished(anim_name))
		add_user_signal(_get_user_signal_updated(anim_name))


func _get_user_signal_started(animation: StringName) -> StringName:
	return "_%s_started" % animation

func _get_user_signal_finished(animation: StringName) -> StringName:
	return "_%s_finished" % animation

func _get_user_signal_updated(animation: StringName) -> StringName:
	return "_%s_updated" % animation


func _emit_anim_started(animation: StringName) -> void:
	animation_started.emit(animation)

	if has_user_signal(_get_user_signal_started(animation)):
		emit_signal(_get_user_signal_started(animation))

func _emit_anim_finished(animation: StringName) -> void:
	animation_started.emit(animation)

	if has_user_signal(_get_user_signal_finished(animation)):
		emit_signal(_get_user_signal_finished(animation))

func _emit_anim_updated(animation: StringName, play_position: float) -> void:
	animation_updated.emit(animation, play_position)

	if has_user_signal(_get_user_signal_updated(animation)):
		emit_signal(_get_user_signal_updated(animation), play_position)
