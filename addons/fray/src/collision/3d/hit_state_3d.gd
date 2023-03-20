@tool
@icon("res://addons/fray/assets/icons/hit_state_3d.svg")
class_name FrayHitState3D 
extends Node3D
## Node used to contain and manage [FrayHitbox3D]s
## 
## This node allows you to manage multiple hitboxes from a single access point.
## It is intended to represent how a fighter is attacking or can be attacked
## while in a specific state such as when performing an attack.

const _ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")

## Emitted when the received [kbd]detected_hitbox[/kbd] enters the child [kbd]detector_hitbox[/kbd]. 
## Requires child [FrayHitbox3D.monitoring] to be set to [code]true[/code].
signal hitbox_intersected(detector_hitbox: FrayHitbox3D, detected_hitbox: FrayHitbox3D)

## Emitted when the received [kbd]detected_hitbox[/kbd] enters the child [kbd]detector_hitbox[/kbd]. 
## Requires child [FrayHitbox3D.monitoring] to be set to [code]true[/code].
signal hitbox_separated(detector_hitbox: FrayHitbox3D, detected_hitbox: FrayHitbox3D)

## Emitted when the active hitboxes of this hit state are changed.
signal active_hitboxes_changed()

## Source of the [FrayHitbox3D]s beneath this node.
## [br]
## This is a convinience that allows you to set the hitbox source from the inspector.
## However, this property only allows nodes to be used as sources.
## Any object can be used by calling [member set_hitbox_source].
var source: Node = null:
	set(value):
		source = value
		set_hitbox_source(value)

## Bit flag used to set which hitbox is and isn't active.
var active_hitboxes: int = 0:
	set(value):
		active_hitboxes = value

		var i := 0
		for child in get_children():
			if child is FrayHitbox3D:
				if (1 << i) & value != 0:
					child.activate()
				else:
					child.deactivate()
				i += 1

		active_hitboxes_changed.emit()

var is_active: bool:
	get: return _is_active
	set(value):
		push_warning("Property is readonly.")

var _is_active: bool
var _cc_detector: _ChildChangeDetector


func _init() -> void:
	set_meta("_editor_prop_ptr_source", NodePath())


func _ready() -> void:
	if Engine.is_editor_hint():
		return


	for child in get_children():
		if child is FrayHitbox3D:
			child.hitbox_entered.connect(_on_Hitbox_hitbox_entered.bind(child))
			child.hitbox_exited.connect(_on_Hitbox_hitbox_exited.bind(child))


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_cc_detector = _ChildChangeDetector.new(self)
		_cc_detector.child_changed.connect(_on_ChildChangeDetector_child_changed)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not get_children().any(func(node): return node is FrayHitbox3D):
		warnings.append("This node has no hitboxes so it can not be activated. Consider adding a FrayHitbox3D as a child.")
	
	return warnings


func _set(property: StringName, value) -> bool:
	match property:
		"metadata/_editor_prop_ptr_source":
			var node: Node = get_node_or_null(value) as Node
			if value.is_empty() or node == null:
				set_meta("_editor_prop_ptr_source", NodePath())
				source = null
			else:
				set_meta("_editor_prop_ptr_source", value)
				source = node
			return true
	return false


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	var hint_string := ""

	for i in get_child_count():
		var child := get_child(i)
		if child is FrayHitbox3D:
			hint_string += "(%d) %s" % [i, child.name] 
			
			if i != get_child_count() - 1:
				hint_string += ","

	properties.append({
		"name": "source",
		"type": TYPE_OBJECT,
		"usage": 
			PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY
			if get_parent() is FrayHitStateManager3D else
			PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NODE_TYPE,
	})
	
	if hint_string.is_empty():
		properties.append({
			"name": "active_hitboxes",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "NONE"
		})
	else:
		properties.append({
			"name": "active_hitboxes",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_FLAGS,
			"hint_string": hint_string
		})
	
	return properties

## Returns [code]true[/code] if the hitbox at the given [kbd]index[/kbd] is active.
func is_hitbox_active(index: int) -> bool:
	return active_hitboxes & (1 << index) != 0

## Sets whether the hitbox at the given [kbd]index[/kbd] is active or not.
func set_hitbox_active(index: int, is_active: bool) -> void:
	var flag = 1 << index
	
	if flag > active_hitboxes:
		push_warning("Index out of bounds.")
		return
	
	if is_active:
		active_hitboxes |= flag
	else:
		active_hitboxes &= flag

## Returns a list of all hitbox children belonging to this hit state.
func get_hitboxes() -> Array[FrayHitbox3D]:
	var array: Array

	for child in get_children():
		if child is FrayHitbox3D:
			array.append(child)

	return array

## Sets the [kbd]source[/kbd] of all [FrayHitbox3D] children.
func set_hitbox_source(source: Object) -> void:
	for child in get_children():
		if child is FrayHitbox3D:
			child.source = source

## Activates all hitbox children belonging to this state.
func activate() -> void:
	_is_active = true
	show()

## Deactivates all hitbox children belonging to this state.
func deactivate() -> void:
	if _is_active:
		_is_active = false
		for child in get_children():
			if child is FrayHitbox3D:
				child.deactivate()
	hide()


func _on_Hitbox_hitbox_entered(detected_hitbox: FrayHitbox3D, detector_hitbox: FrayHitbox3D) -> void:
	hitbox_intersected.emit(detector_hitbox, detected_hitbox)


func _on_Hitbox_hitbox_exited(detected_hitbox: FrayHitbox3D, detector_hitbox: FrayHitbox3D) -> void:
	hitbox_separated.emit(detector_hitbox, detected_hitbox)


func _on_ChildChangeDetector_child_changed(node: Node, change: _ChildChangeDetector.Change) -> void:
	notify_property_list_changed()
