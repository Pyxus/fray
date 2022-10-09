tool
extends Area
## 3D area intended to detect combat interactions.

signal hitbox_intersected(hitbox)
signal hitbox_seperated(hitbox)

var Hitbox2D = load("res://addons/fray/src/collision/3d/hitbox_3d.gd") # Cyclic depedencies... >:[

## If true then hitboxes that share the same source as this one will still be detected
export var detect_source_hitboxes: bool = false

## The HitboxAttributes resource containing the attributes of this hitbox
## Type: HitboxAttributes
export var attributes: Resource

## Source of the hitbox. 
## Can be used to prevent hitboxes produced by the same object from interacting
var source: Object setget set_source

## Type: Hitbox2D[]
var _hitbox_exceptions: Array

## Type: Object[]
var _source_exceptions: Array


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


## Returns all list of all interesecting hitboxes that thix hitbox can detect.
func get_overlapping_hitboxes() -> Array:
	var hitboxes: Array
	for area in get_overlapping_areas():
		if can_detect(area):
			hitboxes.append(area)
	return hitboxes

## Adds a hitbox to a list of hitboxes this hitbox can't detect
func add_hitbox_exception_with(hitbox: Area2D) -> void:
	if hitbox is Hitbox2D and not _hitbox_exceptions.has(hitbox):
		_hitbox_exceptions.append(hitbox)
	
## Removes a hitbox to a list of hitboxes this hitbox can't detect
func remove_hitbox_exception_with(hitbox: Area2D) -> void:
	if _hitbox_exceptions.has(hitbox):
		_hitbox_exceptions.erase(hitbox)

## Adds a source to a list of sources whose hitboxes this hitbox can't detect
func add_source_exception_with(source: Object) -> void:
	if not _source_exceptions.has(source):
		_source_exceptions.append(source)
	
## Removes a source to a list of sources whose hitboxes this hitbox can't detect
func remove_source_exception_with(source: Object) -> void:
	if _source_exceptions.has(source):
		_source_exceptions.erase(source)
		
## Activates this hitbox allowing it to monitor and be monitored.
func activate() -> void:
	monitorable = true
	monitoring = true

## Deactivates this hitobx preventing it from monitoring and being monitored.
func deactivate() -> void:
	monitorable = false
	monitoring = false

## Returns true if this hitbox is able to detect the given hitbox.
## A hitbox can not detect another hitbox if there is a source or hitbox exception
## or if the set hitbox attribute does not allow interaction with the given hitbox. 
func can_detect(hitbox: Area2D) -> bool:
	return (
		hitbox is Hitbox2D
		and not _hitbox_exceptions.has(hitbox)
		and not _source_exceptions.has(hitbox.source)
		and detect_source_hitboxes or hitbox.source != source
		and attributes.allows_detection_of(hitbox) 
			if attributes != null else true
		)
	

func set_source(value: Object) -> void:
	source = value


func _on_area_entered(hitbox: Area2D) -> void:
	if can_detect(hitbox):
		emit_signal("hitbox_intersected", hitbox)


func _on_area_exited(hitbox: Area2D) -> void:
	if can_detect(hitbox):
		emit_signal("hitbox_seperated", hitbox)
