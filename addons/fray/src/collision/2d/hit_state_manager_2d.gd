@tool
@icon("res://addons/fray/assets/icons/hit_state_manager_2d.svg")
class_name FrayHitStateManager2D
extends Node2D
## Node used to enforce discrete hit states.
## 
## This node only allows one hit state child to be active at a time.
## When [member FrayHitState2D.active_hitboxes] changes all other hit states will be deactivate.

const _ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const _SignalUtils = preload("res://addons/fray/lib/helpers/utils/signal_utils.gd")

## Emitted when the received [kbd]detected_hitbox[/kbd] enters the child [kbd]detector_hitbox[/kbd]. 
## Requires child [FrayHitbox2D.monitoring] to be set to [code]true[/code].
signal hitbox_intersected(detector_hitbox: FrayHitbox2D, detected_hitbox: FrayHitbox2D)

## Emitted when the received [kbd]detected_hitbox[/kbd] enters the child [kbd]detector_hitbox[/kbd]. 
## Requires child [FrayHitbox2D.monitoring] to be set to [code]true[/code].
signal hitbox_separated(detector_hitbox: FrayHitbox2D, detected_hitbox: FrayHitbox2D)

## Source of the [FrayHitbox2D]s beneath this node.
## [br]
## This is a convinience that allows you to set the hitbox source from the inspector.
## However, this property only allows nodes to be used as sources.
## Any object can be used by calling [member set_hitbox_source].
@export var source: Node = null:
	set(value):
		source = value
		
		for child in get_children():
			if child is FrayHitState2D:
				child["metadata/_editor_prop_ptr_source"] = (
					child.get_path_to(source) if source else NodePath()
					)
		set_hitbox_source(value)

var _current_state: StringName = ""
var _cc_detector: _ChildChangeDetector

func _ready() -> void:
	if Engine.is_editor_hint(): 
		return
	
	for child in get_children():
		if child is FrayHitState2D:
			child.set_hitbox_source(source)
			child.hitbox_intersected.connect(_on_Hitstate_hitbox_intersected)
			child.hitbox_intersected.connect(_on_Hitstate_hitbox_separated)
			child.active_hitboxes_changed.connect(_on_HitState_active_hitboxes_changed.bind(child))


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if get_children().any(func(node): node is FrayHitState2D):
		warnings.append("This node has no hit states so there is nothing to manage. Consider adding a FrayHitState2D as a child.")
	
	return warnings


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_cc_detector = _ChildChangeDetector.new(self)
		_cc_detector.child_changed.connect(_on_ChildChangeDetector_child_changed)


func _set(property: StringName, value) -> bool:
	match property:
		"metadata/_editor_prop_ptr_source":
			var node: Node = get_node_or_null(value) as Node
			if value.is_empty() or node == null:
				set_meta("_editor_prop_ptr_source", NodePath())
				source = null
			else:
				set_meta("_editor_prop_ptr_source", value)
				source = node
			return true
	return false

## Returns the name of the current hit state
func get_current_state() -> StringName:
	return _current_state

## Returns a reference to the current state. Returns null if no state is set.
func get_current_state_obj() -> FrayHitState2D:
	return get_node_or_null(NodePath(_current_state)) as FrayHitState2D

## Sets the [kbd]source[/kbd] of all [FrayHitbox2D] beneath this node.
func set_hitbox_source(source: Object) -> void:
	for child in get_children():
		if child is FrayHitState2D:
			child.set_hitbox_source(source)


func _set_current_state(new_current_state: StringName) -> void:
	if new_current_state != _current_state:
		_current_state = new_current_state

		for child in get_children():
			if child is FrayHitState2D and child.name != _current_state:
				child.deactivate()


func _on_ChildChangeDetector_child_changed(node: Node, change: _ChildChangeDetector.Change) -> void:
	if change == _ChildChangeDetector.Change.ADDED:
		set_deferred("source", source)

	if node is FrayHitState2D and change != _ChildChangeDetector.Change.REMOVED:
		_SignalUtils.safe_connect(node.active_hitboxes_changed, _on_HitState_active_hitboxes_changed, [node])


func _on_Hitstate_hitbox_intersected(detector_hitbox: FrayHitbox2D, detected_hitbox: FrayHitbox2D) -> void:
	emit_signal("hitbox_intersected", detector_hitbox, detected_hitbox)


func _on_Hitstate_hitbox_separated(detector_hitbox: FrayHitbox2D, detected_hitbox: FrayHitbox2D) -> void:
	emit_signal("hitbox_separated", detector_hitbox, detected_hitbox)


func _on_HitState_active_hitboxes_changed(hitstate: FrayHitState2D) -> void:
	_set_current_state(hitstate.name)
	hitstate.activate()
