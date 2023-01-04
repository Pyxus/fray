@tool
class_name Hitbox2D 
extends Area2D
@icon("res://addons/fray/assets/icons/hitbox_2d.svg")
## 2D area intended to detect combat interactions.

## Emitted when the received [kbd]hitbox[/kbd] enters this hitbox. Requires monitoring to be set to [code]true[/code].
signal hitbox_entered(hitbox: Hitbox2D)

## Emitted when the received [kbd]hitbox[/kbd] exits this hitbox. Requires monitoring to be set to [code]true[/code].
signal hitbox_exited(hitbox: Hitbox2D)

## If true then hitboxes that share the same source as this one will still be detected
@export var detect_source_hitboxes: bool = false

## The assigned [HitboxAttributes]
@export var attributes: HitboxAttributes

## Source of this hitbox. 
## By default hitboxes with the same source will not detect one another.
## This can be changed by enabling [member detect_srouce_hitboxes].
var source: Object = null

var _hitbox_exceptions: Array[Hitbox2D]
var _source_exceptions: Array[Object]


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

## Returns a list of intersecting [Hitbox2D]s.
func get_overlapping_hitboxes() -> Array[Hitbox2D]:
	var hitboxes: Array[Hitbox2D]
	for area in get_overlapping_areas():
		if can_detect(area):
			hitboxes.append(area)
	return hitboxes

## Adds a hitbox to a list of hitboxes this hitbox can't detect
func add_hitbox_exception_with(hitbox: Area2D) -> void:
	if hitbox is Hitbox2D and not _hitbox_exceptions.has(hitbox):
		_hitbox_exceptions.append(hitbox)
	
## Removes a hitbox from a list of hitboxes this hitbox can't detect
func remove_hitbox_exception_with(hitbox: Area2D) -> void:
	if _hitbox_exceptions.has(hitbox):
		_hitbox_exceptions.erase(hitbox)

## Adds a source to a list of sources whose hitboxes this hitbox can't detect
func add_source_exception_with(obj: Object) -> void:
	if not _source_exceptions.has(obj):
		_source_exceptions.append(obj)
	
## Removes a source to a list of sources whose hitboxes this hitbox can't detect
func remove_source_exception_with(obj: Object) -> void:
	if _source_exceptions.has(obj):
		_source_exceptions.erase(obj)
		
## Activates this hitbox allowing it to monitor and be monitored.
func activate() -> void:
	monitorable = true
	monitoring = true
	show()

## Deactivates this hitobx preventing it from monitoring and being monitored.
func deactivate() -> void:
	monitorable = false
	monitoring = false
	hide()

## Returns [code]true[/code] if this hitbox is able to detect the given [kbd]hitbox[/kbd].
## [br]
## A hitbox can not detect another hitbox if there is a source or hitbox exception
## or if the set hitbox attribute does not allow interaction with the given hitbox. 
func can_detect(hitbox: Hitbox2D) -> bool:
	return (
		hitbox is Hitbox2D
		and not _hitbox_exceptions.has(hitbox)
		and not _source_exceptions.has(hitbox.source)
		and detect_source_hitboxes or hitbox.source != source
		and attributes.allows_detection_of(hitbox.attributes)
			if attributes != null else true
		)
	
	
func _on_area_entered(hitbox: Area2D) -> void:
	if can_detect(hitbox):
		hitbox_entered.emit(hitbox)


func _on_area_exited(hitbox: Area2D) -> void:
	if can_detect(hitbox):
		hitbox_exited.emit(hitbox)
