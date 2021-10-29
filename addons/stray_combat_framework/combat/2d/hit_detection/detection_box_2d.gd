tool
extends Area2D
## 2D area intended to detect combat interactions.
## 
## Serves as the base class for AttackBox and HurtBox.

#inner classes

signal activated()
signal deactivated()

#enums

#constants

var DetectionBox2D = load("res://addons/stray_combat_framework/combat/2d/hit_detection/detection_box_2d.gd")

export var flip_h: bool setget set_flip_h
export var flip_v: bool setget set_flip_v

var is_active: bool setget set_is_active
var belongs_to: Object

var _detection_exceptions: Array

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	set_is_active(is_active)
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")

#remaining built-in virtual methods

func add_detection_exception_with(hitbox: Area2D) -> void:
	assert(hitbox.get_script() == get_script(), "Argument is not of type Hitbox")
	
	if not _detection_exceptions.has(hitbox):
		_detection_exceptions.append(hitbox)
	
func remove_detection_exception_with(hitbox: Area2D) -> void:
	assert(hitbox.get_script() == get_script(), "Argument is not of type Hitbox")
	
	if _detection_exceptions.has(hitbox):
		_detection_exceptions.erase(hitbox)

func set_flip_h(value: bool) -> void:
	flip_h = value
	
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.position.x *= -1
	
func set_flip_v(value: bool) -> void:
	flip_v = value
	
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.position.y *= -1

func set_is_active(value: bool) -> void:
	if is_active != value:
		if value:
			show()
			monitorable = true
			monitoring = true
			emit_signal("activated")
		else:
			hide()
			monitorable = false
			monitoring = false
			emit_signal("deactivated")
		
	is_active = value

#private methods

func _on_area_entered(area: Area2D) -> void:
	pass

func _on_area_exited(area: Area2D) -> void:
	pass
