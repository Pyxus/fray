@tool
@icon("res://addons/fray/assets/icons/hitbox_3d.svg")
class_name FrayHitbox3D
extends Area3D

## 3D area intended to detect combat interactions.
##
## The hitbox node doesn't provide much functionality out of the box.
## It serves as a template you can expand upon through the use of [FrayHitboxAttributes]

## Emitted when the received [kbd]hitbox[/kbd] enters this hitbox. Requires monitoring to be set to [code]true[/code].
signal hitbox_entered(hitbox: FrayHitbox3D)

## Emitted when the received [kbd]hitbox[/kbd] exits this hitbox. Requires monitoring to be set to [code]true[/code].
signal hitbox_exited(hitbox: FrayHitbox3D)

## If true then hitboxes that share the same source as this one will still be detected
@export var detect_source_hitboxes: bool = false

## The [FrayHitboxAttributes] assigned to this hitbox
@export var attributes: FrayHitboxAttributes:
	set(value):
		attributes = value
		
		if attributes != null:
			_update_collision_colors()
		
		update_configuration_warnings()

## Source of this hitbox. 
## Hitboxes with the same source will not detect one another unless [member detect_source_hitboxes] is enabled.
var source: Object = null

var _hitbox_exceptions: Array[FrayHitbox3D]
var _source_exceptions: Array[Object]
var _debug_meshes: Array[MeshInstance3D]


func _ready() -> void:
	if Engine.is_editor_hint():
		child_entered_tree.connect(
			func(node: Node): 
				if node is CollisionShape3D:
					_update_collision_colors()
				)
		child_exiting_tree.connect(
			func(node: Node): 
				if node is CollisionShape3D:
					_update_collision_colors()
				)
		return
		
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if attributes == null:
		warnings.append("Hitboxes without attributes are effectively just Area3Ds. Consider giving this node a FrayHitboxAttributes resource.")
	return warnings

## Returns a list of intersecting [FrayHitbox3D]s.
func get_overlapping_hitboxes() -> Array[FrayHitbox3D]:
	var hitboxes: Array[FrayHitbox3D]
	for area in get_overlapping_areas():
		if can_detect(area):
			hitboxes.append(area)
	return hitboxes

## Adds a [kbd]hitbox[/kbd] to a list of hitboxes this hitbox can't detect
func add_hitbox_exception_with(hitbox: FrayHitbox3D) -> void:
	if hitbox is FrayHitbox3D and not _hitbox_exceptions.has(hitbox):
		_hitbox_exceptions.append(hitbox)
	
## Removes a [kbd]hitbox[/kbd] from a list of hitboxes this hitbox can't detect
func remove_hitbox_exception_with(hitbox: FrayHitbox3D) -> void:
	if _hitbox_exceptions.has(hitbox):
		_hitbox_exceptions.erase(hitbox)

## Adds a source [kbd]object[/kbd] to a list of sources whose hitboxes this hitbox can't detect
func add_source_exception_with(object: Object) -> void:
	if not _source_exceptions.has(object):
		_source_exceptions.append(object)
	
## Removes a source [kbd]object[/kbd] to a list of sources whose hitboxes this hitbox can't detect
func remove_source_exception_with(object: Object) -> void:
	if _source_exceptions.has(object):
		_source_exceptions.erase(object)
		
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
func can_detect(hitbox: FrayHitbox3D) -> bool:
	return (
		not _hitbox_exceptions.has(hitbox)
		and not _source_exceptions.has(hitbox.source)
		and detect_source_hitboxes or hitbox.source != source
		and attributes.allows_detection_of(hitbox.attributes)
			if attributes != null else true
		)
	

func _update_collision_colors() -> void:
	if attributes != null and _are_collision_shapes_visible():
		## TODO: Finish implementation
		return
		
		var mat := StandardMaterial3D.new()
		mat.albedo_color = attributes.get_color()
		
		for mesh in _debug_meshes:
			mesh.queue_free()

		for node in get_children():
			if node is CollisionShape3D and node.shape != null:
				var mesh := MeshInstance3D.new()
				mesh.material_override = mat
				mesh.mesh = node.shape.get_debug_mesh()
				add_child(mesh)
				

func _are_collision_shapes_visible() -> bool:
	return (is_inside_tree() and get_tree().debug_collisions_hint) or Engine.is_editor_hint()
	
func _on_area_entered(area: Area3D) -> void:
	if area is FrayHitbox3D and can_detect(area):
		hitbox_entered.emit(area)


func _on_area_exited(area: Area3D) -> void:
	if area is FrayHitbox3D and can_detect(area):
		hitbox_exited.emit(area)
