class_name FrayAnimatorTracker
extends Resource

## Emitted when the observed animation controller reaches the start of the animation.
signal animation_started(animation: StringName)

## Emitted when the observed animation controller reaches the end of the animation.
signal animation_finished(animation: StringName)

## Emited when the observed animation controller updates the animation progress.
signal animation_updated(animation: StringName, play_position: float)

## func(node: [Node]) -> [NodePath]
## [br]
## Returns the path from a given node to the tracker property of the observer containing this tracker..
var fn_get_path_from: Callable = Callable()

## Readies this tracker.
## [br]
## This method is only intended to be used by the [FrayAnimationObserver].
func ready() -> void:
	_add_anim_signals(_get_animation_list_impl())
	_ready_impl()

## Processes this tracker.
## [br]
## This method is only intended to be used by the [FrayAnimationObserver].
func process(delta: float) -> void:
	_process_impl(delta)

## Physics process this tracker.
## [br]
## This method is only intended to be used by the [FrayAnimationObserver].
func physics_process(delta: float) -> void:
	_physics_process_impl(delta)


## [code]Virtual method[/code] invoked when the [FrayAnimationObserver] using this tracker is readied.
func _ready_impl() -> void:
	pass


## [code]Virtual method[/code] invoked when the tracker is being processed. [kbd]delta[/kbd] is in seconds.
func _process_impl(delta: float) -> void:
	pass


## [code]Virtual method[/code] invoked when the tracker is being processed. [kbd]delta[/kbd] is in seconds.
func _physics_process_impl(delta: float) -> void:
	pass


## Used to emit an animation started signal. Emits both built-in signal and per-animation user signal.
func emit_anim_started(animation: StringName) -> void:
	animation_started.emit(animation)

	if has_user_signal(format_usignal_started(animation)):
		emit_signal(format_usignal_started(animation))


## Used to emit an animation finished signal. Emits both built-in signal and per-animation user signal.
func emit_anim_finished(animation: StringName) -> void:
	animation_started.emit(animation)

	if has_user_signal(format_usignal_finished(animation)):
		emit_signal(format_usignal_finished(animation))


## Used to emit an animation updated signal. Emits both built-in signal and per-animation user signal.
func emit_anim_updated(animation: StringName, play_position: float) -> void:
	animation_updated.emit(animation, play_position)

	if has_user_signal(format_usignal_updated(animation)):
		emit_signal(format_usignal_updated(animation), play_position)


## Returns the given [kbd]animation[/kbd] string formatted as a 'started' user signal.
func format_usignal_started(animation: StringName) -> StringName:
	return "_%s_started" % animation


## Returns the given [kbd]animation[/kbd] string formatted as a 'finished' user signal.
func format_usignal_finished(animation: StringName) -> StringName:
	return "_%s_finished" % animation


## Returns the given [kbd]animation[/kbd] string formatted as a 'updated' user signal.
func format_usignal_updated(animation: StringName) -> StringName:
	return "_%s_updated" % animation


## [code]Abstract method[/code] used to return the list of animations beloning to the tracked animator.
## This list is used to initialize the per-animation user signals.
func _get_animation_list_impl() -> Array[String]:
	assert(false, "Method not implemented")
	return []


func _add_anim_signals(animation_list: Array[String]) -> void:
	for anim_name in animation_list:
		add_user_signal(format_usignal_started(anim_name))
		add_user_signal(format_usignal_finished(anim_name))
		add_user_signal(format_usignal_updated(anim_name))
