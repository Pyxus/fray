@tool
class_name HitState2D
extends Node2D
@icon("res://addons/fray/assets/icons/hit_state_2d.svg")
## Node used to contain a configuration of Hitboxe2Ds
##
## 
## This node is intended to represent how a fighter is attacking or can be attacked
## at a given moment.

## Emitted when the received [kbd]detected_hitbox[/kbd] enters the child [kbd]detector_hitbox[/kbd]. 
## Requires [Hitbox2D.monitoring] to be set to [code]true[/code].
signal hitbox_intersected(detector_hitbox: Hitbox2D, detected_hitbox: Hitbox2D)

## Emitted when the received [kbd]detected_hitbox[/kbd] enters the child [kbd]detector_hitbox[/kbd]. 
## Requires [Hitbox2D.monitoring] to be set to [code]true[/code].
signal hitbox_seperated(detector_hitbox: Hitbox2D, detected_hitbox: Hitbox2D)

## Emitted when the received [kbd]hitbox[/kbd] enters this hitbox. Requires monitoring to be set to [code]true[/code].
signal activated()

## Flag used to determine which hitbox is and isn't active.
var active_hitboxes: int = 0:
	set(value):
		active_hitboxes = value

		var i := 0
		for child in get_children():
			if child is Hitbox2D:
				if (1 << i) & value != 0:
					child.activate()
				else:
					child.deactivate()
				i += 1

		activated.emit()

var _is_active: bool


func _ready() -> void:
	for child in get_children():
		if child is Hitbox2D:
			child.hitbox_entered.connect(_on_Hitbox_hitbox_entered.bind(child))
			child.hitbox_exited.connect(_on_Hitbox_hitbox_exited.bind(child))


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		get_tree().tree_changed.connect(_on_SceneTree_tree_changed)


func _get_configuration_warning() -> String:
	for child in get_children():
		if child is Hitbox2D:
			return ""
	
	return "This node has no hitboxes so it can not be activated. Consider adding a Hitbox2D as a child."


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	var hint_string := ""
	var hint := PROPERTY_HINT_FLAGS
	
	for i in get_child_count():
		var child := get_child(i)
		if child is Hitbox2D:
			hint_string += "(%d) %s" % [i, child.name] 
			
			if i != get_child_count() - 1:
				hint_string += ","

	if hint_string.is_empty():
		hint = PROPERTY_HINT_ENUM
		hint_string = "NONE"

	properties.append({
		"name": "active_hitboxes",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": hint,
		"hint_string": hint_string
	})

	return properties

## Returns [code]true[/code] if the hitbox at the given [kbd]index[/kbd] is active.
func is_hitbox_active(index: int) -> bool:
	return active_hitboxes & (1 << index) != 0

## Sets whether the hitbox at the given [kbd]index[/kbd] is active or not.
func set_active_hitbox(index: int, is_active: bool) -> void:
	if is_active:
		active_hitboxes |= (1 << index)
	else:
		active_hitboxes &= (1 << index)

## Returns a list of all hitbox children belonging to this hit state.
func get_hitboxes() -> Array[Hitbox2D]:
	var array: Array

	for child in get_children():
		if child is Hitbox2D:
			array.append(child)

	return array

## Sets the [kbd]source[/kbd] of all hitbox children.
func set_hitbox_source(source: Object) -> void:
	for child in get_children():
		if child is Hitbox2D:
			child.source = source

## Activates all hitbox children belonging to this state.
func activate() -> void:
	_is_active = true
	show()

## Deactivates all hitbox children belonging to this state.
func deactivate() -> void:
	if _is_active:
		_is_active = false
		active_hitboxes = 0
		for child in get_children():
			if child is Hitbox2D:
				child.deactivate()
	hide()


func _on_Hitbox_hitbox_entered(detected_hitbox: Hitbox2D, detector_hitbox: Hitbox2D) -> void:
	hitbox_intersected.emit(detector_hitbox, detected_hitbox)


func _on_Hitbox_hitbox_exited(detected_hitbox: Hitbox2D, detector_hitbox: Hitbox2D) -> void:
	hitbox_seperated.emit(detector_hitbox, detected_hitbox)


func _on_SceneTree_tree_changed() -> void:
	notify_property_list_changed()
