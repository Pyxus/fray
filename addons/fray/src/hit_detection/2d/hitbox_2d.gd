tool
extends Area2D
## 2D area intended to detect combat interactions.

# Imports
const HitAttributes = preload("../hit_attributes.gd")
var Hitbox2D = load("res://addons/fray/src/hit_detection/2d/hitbox_2d.gd")

signal hit_box_detected()
signal activated()
signal deactivated()

#enums

export var hit_attributes: Resource setget set_hit_attributes # Custom resource exports would be pretty nice godot ¬¬
export var is_active: bool setget set_is_active
export var flip_h: bool setget set_flip_h
export var flip_v: bool setget set_flip_v

## Source of the hitbox. Can be used to prevent hitboxes produced by the same entity from interacting
var source: Object setget set_source

var _detection_exceptions: Array

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	set_is_active(is_active)
	connect("area_entered", self, "_on_area_entered")


func _process(_delta: float) -> void:
	if Engine.editor_hint:
		modulate = hit_attributes.get_color() if hit_attributes != null else Color.black
		return


func set_source(hitbox_source: Object) -> void:
	source = hitbox_source


func set_hit_attributes(value: Resource) -> void:
	if value is HitAttributes:
		hit_attributes = value
	elif value == null:
		hit_attributes = null
	else:
		push_warning("You tried to pass a resource that isn't a hit attribute. If we had custom exports I wouldn't need to do this.")
	
## Adds a hitbox to a list of hitboxes this hitbox can't detect
func add_detection_exception_with(hitbox: Area2D) -> void:
	if hitbox is Hitbox2D and not _detection_exceptions.has(hitbox):
		_detection_exceptions.append(hitbox)
	
## Removes a hitbox to a list of hitboxes this hitbox can't detect
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


func activate() -> void:
	set_is_active(true)


func deactivate() -> void:
	set_is_active(false)


func set_is_active(value: bool) -> void:
	is_active = value
	
	if is_active:
		show()
		monitorable = true
		monitoring = true
		emit_signal("activated")

	else:
		hide()
		monitorable = false
		monitoring = false
		emit_signal("deactivated")
	

func _hitbox_detected(hitbox: Area2D) -> void:
	pass


func _on_area_entered(hitbox: Area2D) -> void:
	if hitbox is Hitbox2D:
		if not _detection_exceptions.has(hitbox) and hitbox.source != source:
			_hitbox_detected(hitbox)