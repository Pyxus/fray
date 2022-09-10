tool
extends Node2D
## Node used to contain a configuration of Hitboxe3Ds
##
## @desc:
## 		This node is intended to represent how a fighter is attacking or can be attacked
##		at a given moment.

const Hitbox3D = preload("hitbox_3d.gd")

signal hitbox_intersected(detector_hitbox, detected_hitbox)
signal hitbox_seperated(detector_hitbox, detected_hitbox)

func _ready() -> void:
	for child in get_children():
		if child is Hitbox3D:
			child.connect("hitbox_intersected", self, "_on_Hitbox_hitbox_intersected", [child])
			child.connect("hitbox_seperated", self, "_on_Hitbox_hitbox_seperated", [child])


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

## Activates all hitbox children belonging to this state.
func activate() -> void:
	show()
	for child in get_children():
		if child is Hitbox3D:
			child.activate()

## Deactivates all hitbox children belonging to this state.
func deactivate() -> void:
	hide()
	for child in get_children():
		if child is Hitbox3D:
			child.deactivate()


func _on_Hitbox_hitbox_intersected(detected_hitbox: Hitbox3D, detector_hitbox: Hitbox3D) -> void:
	emit_signal("hitbox_intersected", detector_hitbox, detected_hitbox)


func _on_Hitbox_hitbox_seperated(detected_hitbox: Hitbox3D, detector_hitbox: Hitbox3D) -> void:
	emit_signal("hitbox_seperated", detector_hitbox, detected_hitbox)
