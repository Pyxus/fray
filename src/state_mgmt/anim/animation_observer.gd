class_name FrayAnimationObserver
extends Node

@export var tracker: FrayAnimatorTracker:
	set(value):
		tracker = value
		tracker.fn_get_path_from = get_path_from
		tracker.fn_get_node = get_node


func _ready() -> void:
	tracker.ready()


func _process(delta: float) -> void:
	tracker.process(delta)


func _physics_process(delta: float) -> void:
	tracker.physics_process(delta)


## Used to connect to the start event of a given animation.
func on_start(animation: String, callable: Callable) -> void:
	tracker.connect(tracker.format_usignal_started(animation), callable)


## Used to connect to the finish event of a given animation.
func on_finish(animation: String, callable: Callable) -> void:
	tracker.connect(tracker.format_usignal_finished(animation), callable)


## Used to connect to the update event of a given anmiation.
func on_update(animation: String, callable: Callable) -> void:
	tracker.connect(tracker.format_usignal_updated(animation), callable)


## Returns the path to this node from the given node.
func get_path_from(from_node: Node) -> NodePath:
	return NodePath(from_node.get_path_to(self))


# These emit methods exist soely because I can't figure out how to call the methods location in the tracker resource
# Which is necessary for my animation tree tracker.
func _emit_anim_started(animation: StringName) -> void:
	tracker.emit_anim_started(animation)


func _emit_anim_finished(animation: StringName) -> void:
	tracker.emit_anim_finished(animation)

func _emit_anim_updated(animation: StringName, play_position: float) -> void:
	tracker.emit_anim_updated(animation, play_position)
