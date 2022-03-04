tool
extends Node2D
## docstring

#inner classes

#signals

#enums

const NONE = -1

const ChildChangeDetector = preload("res://addons/stray_combat_framework/lib/misc/child_change_detector.gd")

const HitState2D = preload("hit_state_2d.gd")

export var switch_on_state_activated: bool = true
export var belongs_to: NodePath setget set_belongs_to

var _cc_detector: ChildChangeDetector
var _current_hit_state: HitState2D

#onready variables


#optional built-in virtual _init method


func _enter_tree() -> void:
	_cc_detector = ChildChangeDetector.new(self)
	_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func _get_configuration_warning() -> String:
	if not has_hit_states():
		return "This node is expected to have HitState2D children."
	return ""


func get_current_hit_state() -> HitState2D:
	return _current_hit_state


func _set_current_hitstate(hit_state: HitState2D) -> void:
	if _current_hit_state == hit_state:
		return

	for h_state in get_hit_states():
		if h_state != hit_state:
			h_state.is_active = false

	_current_hit_state = hit_state
	hit_state.is_active = true


func set_belongs_to(value: NodePath) -> void:
	belongs_to = value

	for hit_state in get_hit_states():
		hit_state.set_boxes_belong_to(get_node_or_null(belongs_to))


func has_hit_states() -> bool:
	for child in get_children():
		if child is HitState2D:
			return true
	return false


func get_hit_states() -> Array:
	var hit_states := []
	
	for child in get_children():
		if child is HitState2D:
			hit_states.append(child)

	return hit_states


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	match change:
		ChildChangeDetector.Change.ADDED:
			if node is HitState2D:
				if not node.is_connected("activated", self, "_on_HitState_activated"):
					node.connect("activated", self, "_on_HitState_activated", [node])
					node.set_boxes_belong_to(get_node_or_null(belongs_to))

		ChildChangeDetector.Change.REMOVED:
			if node is HitState2D:
				if node.is_connected("activated", self, "_on_HitState_activated"):
					node.disconnect("activated", self, "_on_HitState_activated")
					node.set_boxes_belong_to(null)
	
	

func _on_HitState_activated(hit_state: HitState2D) -> void:
	if switch_on_state_activated:
		_set_current_hitstate(hit_state)
	elif hit_state != _current_hit_state:
		hit_state.is_active = false
	pass
