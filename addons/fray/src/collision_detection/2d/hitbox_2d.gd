tool
extends Area2D
## 2D area intended to detect combat interactions.

signal hitbox_entered(hitbox)

var Hitbox2D = load("res://addons/fray/src/hit_detection/2d/hitbox_2d.gd") # Cyclic depedencies... >:[

## If true then hitboxes that share the same source as this one will still be detected
export var ignore_source_hitboxes: bool = false

## The HitboxAttributes resource containing the attributes of this hitbox
## Type: HitboxAttributes
export var attributes: Resource

## Source of the hitbox. 
## Can be used to prevent hitboxes produced by the same object from interacting
var source: Object setget set_source

## Type: Hitbox2D[]
var _detection_exceptions: Array

func _init() -> void:
	FrayInterface.assert_implements(self, "IHitbox")


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")


## Adds a hitbox to a list of hitboxes this hitbox can't detect
func add_detection_exception_with(hitbox: Area2D) -> void:
	if hitbox is Hitbox2D and not _detection_exceptions.has(hitbox):
		_detection_exceptions.append(hitbox)
	
## Removes a hitbox to a list of hitboxes this hitbox can't detect
func remove_detection_exception_with(hitbox: Area2D) -> void:
	if _detection_exceptions.has(hitbox):
		_detection_exceptions.erase(hitbox)

## Activates this hitbox allowing it to monitor and be monitored.
func activate() -> void:
	monitorable = true
	monitoring = true

## Deactivates this hitobx preventing it from monitoring and being monitored.
func deactivate() -> void:
	monitorable = false
	monitoring = false


func set_source(value: Object) -> void:
	source = value


func _hitbox_entered_impl(hitbox: Area2D) -> void:
	emit_signal("hitbox_entered", hitbox)


func _on_area_entered(hitbox: Area2D) -> void:
	if hitbox is Hitbox2D and not _detection_exceptions.has(hitbox):
		if ignore_source_hitboxes or hitbox.source != source:
			_hitbox_entered_impl(hitbox)
