tool
extends Node2D
## Node used to switch between HitState3D children
## 
## @desc:
##		When a HitState3D child is activated all others will be deactivate.
##		This is a convinience tool for enforcing discrete hit states.

const ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const HitState3D = preload("hit_state_3d.gd")
const Hitbox3D = preload("hitbox_3d.gd")

signal hitbox_intersected(detector_hitbox, detected_hitbox)
signal hitbox_seperated(detector_hitbox, detected_hitbox)

const NONE = "None "

export var source: NodePath

## String name of currently active state
var current_state: String = NONE setget set_current_state

onready var _source: Node
var _cc_detector: ChildChangeDetector


func _ready() -> void:
	_source = get_node_or_null(source)
	
	for child in get_children():
		if child is HitState3D:
			child.set_hitbox_source(_source)
			child.connect("hitbox_intersected", self, "_on_Hitstate_hitbox_intersected")
			child.connect("hitbox_seperated", self, "_on_Hitstate_hitbox_seperated")
			
	set_current_state(current_state)


func _get_configuration_warning() -> String:
	for child in get_children():
		if child is HitState3D:
			return ""
	
	return "This node has no hit states so there is nothing to switch between. Consider adding a HitState3D as a child."
	

func _enter_tree() -> void:
	if Engine.editor_hint:
		_cc_detector = ChildChangeDetector.new(self)
		_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func _get_property_list() -> Array:
	var properties: Array = []
	var hit_states: PoolStringArray = [NONE]
	
	for child in get_children():
		if child is HitState3D:
			hit_states.append(child.name)
	
	properties.append({
		"name": "current_state",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": hit_states.join(",")
	})
	
	return properties

## Returns a reference to the hit state with the given name if it exists.
func get_state_obj(state: String) -> HitState3D:
	var hit_state := get_node_or_null(current_state) as HitState3D
	return hit_state

## Returns a reference to the current state. Returns null if no state is set.
## Shorthand for switcher.get_state_obj(switcher.current_state)
func get_current_state_obj() -> HitState3D:
	return get_state_obj(current_state)

## Setter for 'current_state' property
func set_current_state(value: String) -> void:
	current_state = value

	for child in get_children():
		if child is HitState3D:
			child.deactivate()

	if current_state != NONE and is_inside_tree():
		var hit_state: HitState3D = get_current_state_obj()
		hit_state.activate()


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	property_list_changed_notify()


func _on_Hitstate_hitbox_intersected(detector_hitbox: Hitbox3D, detected_hitbox: Hitbox3D) -> void:
	emit_signal("hitbox_intersected", detector_hitbox, detected_hitbox)


func _on_Hitstate_hitbox_seperated(detector_hitbox: Hitbox3D, detected_hitbox: Hitbox3D) -> void:
	emit_signal("hitbox_seperated", detector_hitbox, detected_hitbox)
