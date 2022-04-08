tool
extends Area2D
## 2D area intended to detect combat interactions.
## 
## Serves as the base class for Attackox and HurtBox.

#inner classes

signal hit_box_detected()
signal activated()
signal deactivated()

#enums

const HitAttributes = preload("../hit_attributes/hit_attributes.gd")

export var hit_attributes: Resource setget set_hit_attributes # Custom resource exports would be pretty nice godot ¬¬
export var is_active: bool setget set_is_active
export var flip_h: bool setget set_flip_h
export var flip_v: bool setget set_flip_v

var box_color: Color = Color.black
var belongs_to: Object

var _detection_exceptions: Array

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	set_is_active(is_active)
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func _process(_delta: float) -> void:
	if Engine.editor_hint:
		modulate = box_color
		return


func set_hit_attributes(value: Resource) -> void:
	if value is HitAttributes:
		hit_attributes = value
		box_color = hit_attributes.get_color()
	elif value == null:
		hit_attributes = null
		box_color = Color.black
	else:
		push_warning("You tried to pass a resource that isn't a hit attribute. If we had custom exports I wouldn't need to do this.")
	
	
func add_detection_exception_with(hitbox: Area2D) -> void:
	if not _detection_exceptions.has(hitbox):
		_detection_exceptions.append(hitbox)
	
	
func remove_detection_exception_with(hitbox: Area2D) -> void:
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
	if not _detection_exceptions.has(area):
		pass


func _on_area_exited(area: Area2D) -> void:
	if not _detection_exceptions.has(area):
		pass
