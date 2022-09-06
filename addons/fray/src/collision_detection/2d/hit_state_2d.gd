tool
extends Node2D
## Node used to contain a configuration of IHitboxes
##
## @desc:
## 		This node is intended to represent how a fighter is attacking or can be attacked
##		at a given moment.
##
##		IHitbox is a pseudo interface, see fray_interface.gd script.
##		Any node that implements the pseudo interface can be managed by the HitState node.

const Hitbox2D = preload("hitbox_2d.gd")

signal hitbox_overlapped(detector_hitbox, detected_hitbox)

func _ready() -> void:
	for child in get_children():
		if child is Hitbox2D:
			child.connect("hitbox_entered", self, "_on_Hitbox_hitbox_entered", [child])

## Sets the source of all Ihitbox children.
## IHitbox is a pseudo interface, see fray_interface.gd script.
func set_hitbox_source(source: Object) -> void:
	for child in get_children():
		if FrayInterface.implements(child, "IHitbox"):
			child.source = source

## Activates all IHitbox children belonging to this state.
## IHitbox is a pseudo interface, see fray_interface.gd script.
func activate() -> void:
	show()
	for child in get_children():
		if FrayInterface.implements(child, "IHitbox"):
			child.activate()

## Deactivates all IHitbox children belonging to this state.
## IHitbox is a pseudo interface, see fray_interface.gd script.
func deactivate() -> void:
	hide()
	for child in get_children():
		if FrayInterface.implements(child, "IHitbox"):
			child.deactivate()


func _on_Hitbox_hitbox_entered(detected_hitbox: Hitbox2D, detector_hitbox: Hitbox2D) -> void:
	emit_signal("hitbox_overlapped", detector_hitbox, detected_hitbox)
