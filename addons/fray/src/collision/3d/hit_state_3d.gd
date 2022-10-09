tool
extends Spatial
## Node used to contain a configuration of Hitboxe3Ds
##
## @desc:
## 		This node is intended to represent how a fighter is attacking or can be attacked
##		at a given moment.

const ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const Hitbox3D = preload("hitbox_3d.gd")

signal hitbox_intersected(detector_hitbox, detected_hitbox)
signal hitbox_seperated(detector_hitbox, detected_hitbox)
signal activated()

var active_hitboxes: int setget set_active_hitboxes

var _cc_detector: ChildChangeDetector

func _ready() -> void:
	for child in get_children():
		if child is Hitbox3D:
			child.connect("hitbox_intersected", self, "_on_Hitbox_hitbox_intersected", [child])
			child.connect("hitbox_seperated", self, "_on_Hitbox_hitbox_seperated", [child])


func _enter_tree() -> void:
	if Engine.editor_hint:
		_cc_detector = ChildChangeDetector.new(self)
		_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func _get_property_list() -> Array:
	var properties: Array = []
	var hitboxes: PoolStringArray
	
	for child in get_children():
		if child is Hitbox3D:
			hitboxes.append(child.name)
	
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
		if child is Hitbox3D:
			array.append(child)

	return array

## Sets the source of all hitbox children.
func set_hitbox_source(source: Object) -> void:
	for child in get_children():
		if child is Hitbox3D:
			child.source = source

func set_active_hitboxes(hitboxes: int) -> void:
	active_hitboxes = hitboxes

	var i := 0
	for child in get_children():
		if child is Hitbox3D:
			if int(pow(2, i)) & hitboxes != 0:
				child.activate()
			else:
				child.deactivate()
			i += 1

	emit_signal("activated")

## Activates all hitbox children belonging to this state.
func activate() -> void:
	show()

## Deactivates all hitbox children belonging to this state.
func deactivate() -> void:
	hide()
	active_hitboxes = 0
	for child in get_children():
		if child is Hitbox3D:
			child.deactivate()


func _on_Hitbox_hitbox_intersected(detected_hitbox: Hitbox3D, detector_hitbox: Hitbox3D) -> void:
	emit_signal("hitbox_intersected", detector_hitbox, detected_hitbox)


func _on_Hitbox_hitbox_seperated(detected_hitbox: Hitbox3D, detector_hitbox: Hitbox3D) -> void:
	emit_signal("hitbox_seperated", detector_hitbox, detected_hitbox)
