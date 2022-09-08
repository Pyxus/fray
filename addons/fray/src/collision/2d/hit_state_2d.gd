tool
extends Node2D
## Node used to contain a configuration of Hitboxe2Ds
##
## @desc:
## 		This node is intended to represent how a fighter is attacking or can be attacked
##		at a given moment.

const Hitbox2D = preload("hitbox_2d.gd")

signal hitbox_intersected(detector_hitbox, detected_hitbox)
signal hitbox_seperated(detector_hitbox, detected_hitbox)

func _ready() -> void:
	for child in get_children():
		if child is Hitbox2D:
			child.connect("hitbox_intersected", self, "_on_Hitbox_hitbox_intersected", [child])
			child.connect("hitbox_seperated", self, "_on_Hitbox_hitbox_seperated", [child])


## Sets the source of all hitbox children.
func set_hitbox_source(source: Object) -> void:
	for child in get_children():
		if child is Hitbox2D:
			child.source = source

## Activates all hitbox children belonging to this state.
func activate() -> void:
	show()
	for child in get_children():
		if child is Hitbox2D:
			child.activate()

## Deactivates all hitbox children belonging to this state.
func deactivate() -> void:
	hide()
	for child in get_children():
		if child is Hitbox2D:
			child.deactivate()


func _on_Hitbox_hitbox_intersected(detected_hitbox: Hitbox2D, detector_hitbox: Hitbox2D) -> void:
	emit_signal("hitbox_intersected", detector_hitbox, detected_hitbox)


func _on_Hitbox_hitbox_seperated(detected_hitbox: Hitbox2D, detector_hitbox: Hitbox2D) -> void:
	emit_signal("hitbox_seperated", detector_hitbox, detected_hitbox)
