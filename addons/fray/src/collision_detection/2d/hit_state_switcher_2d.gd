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

signal hitbox_overlapped(detector_hitbox, detected_hitbox)

const NONE = "None "

export var source: NodePath

var current_state: String = NONE setget set_current_state

onready var _source: Node
var _cc_detector: ChildChangeDetector


func _ready() -> void:
	_source = get_node_or_null(source)
	for child in get_children():
		if child is HitState2D:
			child.set_hitbox_source(_source)
			child.connect("hitbox_overlapped", self, "_on_Hitstate_hitbox_overlapped")
	
	
func _enter_tree() -> void:
	if Engine.editor_hint:
		_cc_detector = ChildChangeDetector.new(self)
		_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func _get_property_list() -> Array:
	var properties: Array = []
	var hit_states: PoolStringArray = [NONE]
	
	for child in get_children():
		if child is HitState2D:
			hit_states.append(child.name)
	
	properties.append({
		"name": "current_state",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": hit_states.join(",")
	})
	
	return properties


func set_current_state(value: String) -> void:
	current_state = value

	for child in get_children():
		if child is HitState2D:
			child.deactivate()

	if current_state != NONE and is_inside_tree():
		var hit_state: HitState2D = get_node_or_null(current_state)
		hit_state.activate()


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	property_list_changed_notify()


func _on_Hitstate_hitbox_overlapped(detector_hitbox: Hitbox2D, detected_hitbox: Hitbox2D) -> void:
	emit_signal("hitbox_overlapped", detector_hitbox, detected_hitbox)
