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
signal hitbox_seperated(detector_hitbox: FrayHitbox2D, detected_hitbox: FrayHitbox2D)


@export var source: Node

var _current_state: String = ""
var _cc_detector: _ChildChangeDetector

func _ready() -> void:
	if Engine.is_editor_hint(): 
		return
	
	for child in get_children():
		if child is FrayHitState2D:
			child.set_hitbox_source(source)
			child.hitbox_intersected.connect(_on_Hitstate_hitbox_intersected)
			child.hitbox_intersected.connect(_on_Hitstate_hitbox_seperated)
			child.active_hitboxes_changed.connect(_on_HitState_active_hitboxes_changed, [child])


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if get_children().any(func(node): node is FrayHitState2D):
		warnings.append("This node has no hit states so there is nothing to manage. Consider adding a FrayHitState2D as a child.")
	
	return warnings


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_cc_detector = _ChildChangeDetector.new(self)
		_cc_detector.child_changed.connect(_on_ChildChangeDetector_child_changed)

## Returns the name of the current hit state
func get_current_state() -> String:
	return _current_state

## Returns a reference to the current state. Returns null if no state is set.
func get_current_state_obj() -> FrayHitState2D:
	return get_node_or_null(_current_state) as FrayHitState2D


func _set_current_state(new_current_state: String) -> void:
	if new_current_state != _current_state:
		_current_state = new_current_state

		for child in get_children():
			if child is FrayHitState2D and child.name != _current_state:
				child.deactivate()


func _on_ChildChangeDetector_child_changed(node: Node, change: _ChildChangeDetector.Change) -> void:
	if node is FrayHitState2D and change != _ChildChangeDetector.Change.REMOVED:
		_SignalUtils.safe_connect(node.active_hitboxes_changed, _on_HitState_active_hitboxes_changed, [node])


func _on_Hitstate_hitbox_intersected(detector_hitbox: FrayHitbox2D, detected_hitbox: FrayHitbox2D) -> void:
	emit_signal("hitbox_intersected", detector_hitbox, detected_hitbox)


func _on_Hitstate_hitbox_seperated(detector_hitbox: FrayHitbox2D, detected_hitbox: FrayHitbox2D) -> void:
	emit_signal("hitbox_seperated", detector_hitbox, detected_hitbox)


func _on_HitState_active_hitboxes_changed(hitstate: FrayHitState2D) -> void:
	_set_current_state(hitstate.name)
	hitstate.activate()
