@tool
class_name FrayAnimationObserver
extends FrayStateMachineComponent
## A node used to observe animation events
##
## The animation player can observe animation events from animators provided by the `FrayAnimatorTracker` resource.
## These events can be subscribed to per-animation using the included 'on' methods.
## The tracker also has event signals which can be connected to in a way that isn't per-animation.

## Used to determine which animator to observe
@export var tracker: FrayAnimatorTracker:
	set(value):
		tracker = value
		tracker.fn_get_path_from = _get_path_from
		tracker.fn_get_node = get_node


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	tracker.ready()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	tracker.process(delta)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	tracker.physics_process(delta)


## Returns a user defined signal which is used to connect to the start event of a given animation.
## [br]
## Signal excepts a method of type [code]func() -> void[/code]
func usignal_started(animation: String) -> Signal:
	return Signal(tracker, tracker.format_usignal_started(animation))


## Returns a user defined signal which is used to connect to the finish event of a given animation.
## [br]
## Signal excepts a method of type [code]func() -> void[/code]
func usignal_finished(animation: String) -> Signal:
	return Signal(tracker, tracker.format_usignal_finished(animation))


## Returns a user defined signal which is used to connect to the update event of a given animation.
## [br]
## Signal excepts a method of type [code]func(play_position: float) -> void[/code]
func usignal_updated(animation: String) -> Signal:
	return Signal(tracker, tracker.format_usignal_updated(animation))


func _get_path_from(from_node: Node) -> NodePath:
	return NodePath(from_node.get_path_to(self))


# region Help wanted
# These emit methods exist solely because I can't figure out how to call the AnimatorTracker methods on an animation track.
# Which is necessary for my approach to animation tree tracking.
func _emit_anim_started(animation: StringName) -> void:
	tracker.emit_anim_started(animation)


func _emit_anim_finished(animation: StringName) -> void:
	tracker.emit_anim_finished(animation)


func _emit_anim_updated(animation: StringName, play_position: float) -> void:
	tracker.emit_anim_updated(animation, play_position)
# endregion