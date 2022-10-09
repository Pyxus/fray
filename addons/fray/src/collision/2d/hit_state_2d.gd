tool
extends Node2D
## Node used to contain a configuration of Hitboxe2Ds
##
## @desc:
## 		This node is intended to represent how a fighter is attacking or can be attacked
##		at a given moment.

const ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const Hitbox2D = preload("hitbox_2d.gd")

signal hitbox_intersected(detector_hitbox, detected_hitbox)
signal hitbox_seperated(detector_hitbox, detected_hitbox)
signal activated()

var active_hitboxes: int setget set_active_hitboxes

var _is_active: bool
var _cc_detector: ChildChangeDetector

func _ready() -> void:
	for child in get_children():
		if child is Hitbox2D:
			child.connect("hitbox_intersected", self, "_on_Hitbox_hitbox_intersected", [child])
			child.connect("hitbox_seperated", self, "_on_Hitbox_hitbox_seperated", [child])


func _enter_tree() -> void:
	if Engine.editor_hint:
		_cc_detector = ChildChangeDetector.new(self)
		_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func _get_configuration_warning() -> String:
	for child in get_children():
		if child is Hitbox2D:
			return ""
	
	return "This node has no hitboxes so it can not be activated. Consider adding a Hitbox2D as a child."
	

func _get_property_list() -> Array:
	var properties: Array = []
	var hitboxes: PoolStringArray
	
	for i in get_child_count():
		var child := get_child(i)
		if child is Hitbox2D:
			hitboxes.append("%d:%s" % [i, child.name])
	if hitboxes.empty():
		properties.append({
			"name": "active_hitboxes",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "NONE"
		})
	else:
		properties.append({
			"name": "active_hitboxes",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"hint": PROPERTY_HINT_FLAGS,
			"hint_string": hitboxes.join(",")
		})

	return properties

## Returns a list of all hitboxes children
func get_hitboxes() -> Array:
	var array: Array

	for child in get_children():
		if child is Hitbox2D:
			array.append(child)

	return array


## Sets the source of all hitbox children.
func set_hitbox_source(source: Object) -> void:
	for child in get_children():
		if child is Hitbox2D:
			child.source = source


func set_active_hitboxes(hitboxes: int) -> void:
	active_hitboxes = hitboxes
	
	var i := 0
	for child in get_children():
		if child is Hitbox2D:
			if int(pow(2, i)) & hitboxes != 0:
				child.activate()
			else:
				child.deactivate()
			i += 1

	emit_signal("activated")

## Activates all hitbox children belonging to this state.
func activate() -> void:
	_is_active = true
	show()

## Deactivates all hitbox children belonging to this state.
func deactivate() -> void:
	if _is_active:
		_is_active = false
		active_hitboxes = 0
		for child in get_children():
			if child is Hitbox2D:
				child.deactivate()
	hide()


func _on_Hitbox_hitbox_intersected(detected_hitbox: Hitbox2D, detector_hitbox: Hitbox2D) -> void:
	emit_signal("hitbox_intersected", detector_hitbox, detected_hitbox)


func _on_Hitbox_hitbox_seperated(detected_hitbox: Hitbox2D, detector_hitbox: Hitbox2D) -> void:
	emit_signal("hitbox_seperated", detector_hitbox, detected_hitbox)


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	property_list_changed_notify()

