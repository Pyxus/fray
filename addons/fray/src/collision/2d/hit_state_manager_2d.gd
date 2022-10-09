tool
extends Node2D
## Node used to switch between HitState2D children
## 
## @desc:
##		When a HitState2D child is activated all others will be deactivate.
##		This is a convinience tool for enforcing discrete hit states.

const ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const HitState2D = preload("hit_state_2d.gd")
const Hitbox2D = preload("hitbox_2d.gd")

signal hitbox_intersected(detector_hitbox, detected_hitbox)
signal hitbox_seperated(detector_hitbox, detected_hitbox)

export var source: NodePath

var _current_state: String = ""
var _cc_detector: ChildChangeDetector

onready var _source: Node


func _ready() -> void:
	if Engine.editor_hint: 
		return

	_source = get_node_or_null(source)
	
	for child in get_children():
		if child is HitState2D:
			child.set_hitbox_source(_source)
			child.connect("hitbox_intersected", self, "_on_Hitstate_hitbox_intersected")
			child.connect("hitbox_seperated", self, "_on_Hitstate_hitbox_seperated")
			child.connect("activated", self, "_on_HitState_activated", [child])


func _get_configuration_warning() -> String:
	for child in get_children():
		if child is HitState2D:
			return ""
	
	return "This node has no hit states so there is nothing to switch between. Consider adding a HitState2D as a child."
	

func _enter_tree() -> void:
	if Engine.editor_hint:
		_cc_detector = ChildChangeDetector.new(self)
		_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")

## Returns a reference to the hit state with the given name if it exists.
func get_current_state() -> String:
	return _current_state

## Returns a reference to the current state. Returns null if no state is set.
## Shorthand for switcher.get_state_obj(switcher.current_state)
func get_current_state_obj() -> HitState2D:
	return get_node_or_null(_current_state) as HitState2D


func _set_current_state(new_current_state: String) -> void:
	if new_current_state != _current_state:
		_current_state = new_current_state

		for child in get_children():
			if child is HitState2D and child.name != _current_state:
				child.deactivate()

		if is_inside_tree():
			var hit_state: HitState2D = get_current_state_obj()
			hit_state.activate()


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	if node is HitState2D and change != ChildChangeDetector.Change.REMOVED:
		if not node.is_connected("activated", self, "_on_HitState_activated"):
			node.connect("activated", self, "_on_HitState_activated", [node])


func _on_Hitstate_hitbox_intersected(detector_hitbox: Hitbox2D, detected_hitbox: Hitbox2D) -> void:
	emit_signal("hitbox_intersected", detector_hitbox, detected_hitbox)


func _on_Hitstate_hitbox_seperated(detector_hitbox: Hitbox2D, detected_hitbox: Hitbox2D) -> void:
	emit_signal("hitbox_seperated", detector_hitbox, detected_hitbox)


func _on_HitState_activated(activated_hitstate: HitState2D) -> void:
	_set_current_state(activated_hitstate.name)