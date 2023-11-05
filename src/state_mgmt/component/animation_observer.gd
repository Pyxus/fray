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


## Used to connect to the start event of a given animation.
## [br]
## [kbd]callable[/kbd] must be of type [code]func() -> void[/code]
func on_start(animation: String, callable: Callable) -> void:
	tracker.connect(tracker.format_usignal_started(animation), callable)


## Used to connect to the finish event of a given animation.
## [br]
## [kbd]callable[/kbd] must be of type [code]func() -> void[/code]
func on_finish(animation: String, callable: Callable) -> void:
	tracker.connect(tracker.format_usignal_finished(animation), callable)


## Used to connect to the update event of a given anmiation.
## The update event is emitted with a 'play_position' argument.
## The meaning of this argument depends on the tracker as it could represent either seconds or frames.
## [br]
## [kbd]callable[/kbd] must be of type [code]func(float) -> void[/code]
func on_update(animation: String, callable: Callable) -> void:
	tracker.connect(tracker.format_usignal_updated(animation), callable)


func _get_path_from(from_node: Node) -> NodePath:
	return NodePath(from_node.get_path_to(self))


# These emit methods exist solely because I can't figure out how to call the AnimatorTracker methods on an animation track.
# Which is necessary for my approach to animation tree tracking.
func _emit_anim_started(animation: StringName) -> void:
	tracker.emit_anim_started(animation)


func _emit_anim_finished(animation: StringName) -> void:
	tracker.emit_anim_finished(animation)

func _emit_anim_updated(animation: StringName, play_position: float) -> void:
	tracker.emit_anim_updated(animation, play_position)
