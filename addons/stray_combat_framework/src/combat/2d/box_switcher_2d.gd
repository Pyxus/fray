tool
extends Node2D
## Node capable of switching between its DetectionBox2D and PushBox2D children.
##
## Only one DetectionBox2D or PushBox2D in a switcher can be active at a time.
## This node is intended to be used when animating by keying the active hitbox.

#inner classes

signal box_activated()
signal active_box_set()

#enums

const NONE = -1

const ReverseableDictionary = preload("res://addons/stray_combat_framework/lib/reversable_dictionary.gd")

const DetectionBox2D = preload("hit_detection/detection_box_2d.gd")
const PushBox2D = preload("body/push_box_2d.gd")

#exported variables

var active_box: int setget set_active_box
var boxes_belong_to: Object setget set_boxes_belong_to

var _detection_box_by_id: Dictionary
var _push_box_by_id: Dictionary
var _box_names: PoolStringArray

#onready variables

func _ready() -> void:
	set_active_box(active_box)


func _enter_tree() -> void:
	var tree := get_tree()
	if tree.is_connected("node_added", self, "_on_SceneTree_node_added"):
		tree.disconnect("node_added", self, "_on_SceneTree_node_added")

	if tree.is_connected("node_removed", self, "_on_SceneTree_node_removed"):
		tree.disconnect("node_removed", self, "_on_SceneTree_node_removed")

	if tree.is_connected("node_renamed", self, "_on_SceneTree_node_renamed"):
		tree.disconnect("node_renamed", self, "_on_SceneTree_node_renamed")


func _get_configuration_warning() -> String:
	if _detection_box_by_id.empty() and _push_box_by_id.empty():
		return "This node is expected to have DetectionBox2Ds or PushBox2Ds children."
	return ""

func _get_property_list() -> Array:
	var properties: Array = []

	properties.append({
	"name": "active_box",
	"type": TYPE_INT,
	"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
	"hint": PROPERTY_HINT_ENUM,
	"hint_string": get_box_names().join(" ,")
	})
	return properties

func deactivate_all_boxes() -> void:
	for detection_box in _detection_box_by_id.values():
		detection_box.is_active = false
	for push_box in _push_box_by_id.values():
		push_box.is_active = false
	active_box = NONE


func set_boxes_belong_to(obj: Object) -> void:
	for detection_box in _detection_box_by_id.values():
		detection_box.belongs_to = obj
	for push_box in _push_box_by_id.values():
		push_box.belongs_to = obj


func set_active_box(value: int) -> void:
	active_box = value

	if is_inside_tree():
		emit_signal("active_box_set")

		if active_box == NONE:
			deactivate_all_boxes()
			return
			
		if _detection_box_by_id.has(active_box):
			_detection_box_by_id[active_box].is_active = true
			
		elif _push_box_by_id.has(active_box):
			_push_box_by_id[active_box].is_active = true
		else:
			push_warning("Active box with given id `%s` does not exist in switcher" % [active_box])

func  get_detection_box_id(detection_box: DetectionBox2D) -> int:
	for id in _detection_box_by_id:
		if _detection_box_by_id[id] == detection_box:
			return id
	return NONE


func  get_push_box_id(push_box: PushBox2D) -> int:
	for id in _push_box_by_id:
		if _push_box_by_id[id] == push_box:
			return id
	return NONE


func get_box_names() -> PoolStringArray:
	var array := PoolStringArray()
	array.append("[NONE]:%d" % NONE)

	for child in get_children():
		if child is DetectionBox2D:
			array.append("%s:%s" % [child.name, get_detection_box_id(child)])
		elif child is PushBox2D:
			array.append("%s:%s" % [child.name, get_push_box_id(child)])

	return array
func _gen_box_id() -> int:
	var id := 0
	while _detection_box_by_id.has(id) or _push_box_by_id.has(id):
		id += 1
	return id


func _add_detection_box(detection_box: DetectionBox2D) -> void:
	if not _detection_box_by_id.values().has(detection_box):
		var box_id := _gen_box_id()
		_detection_box_by_id[box_id] = detection_box
		_box_names.append("%s:%s" % [detection_box.name, box_id])
		detection_box.connect("activated", self, "_on_DetectionBox2D_activated", [detection_box])
		property_list_changed_notify()


func _add_push_box(push_box: PushBox2D) -> void:
	if not _push_box_by_id.values().has(push_box):
		var box_id := _gen_box_id()
		_detection_box_by_id[box_id] = push_box
		_box_names.append("%s:%s" % [push_box.name, box_id])
		push_box.connect("activated", self, "_on_PushBox2D_actiavted", [push_box])
		property_list_changed_notify()


func _remove_detection_box(detection_box: Node) -> void:
	for id in _detection_box_by_id:
		if _detection_box_by_id[id] == detection_box:
			if detection_box.is_connected("activated", self, "_on_DetectionBox2D_activated"):
				detection_box.disconnect("activated", self, "_on_DetectionBox2D_activated")
			_detection_box_by_id.erase(id)
			property_list_changed_notify()


func _remove_push_box(push_box: Node) -> void:
	for id in _detection_box_by_id:
		if _detection_box_by_id[id] == push_box:
			if push_box.is_connected("activated", self, "_on_PushBox2D_activated"):
				push_box.disconnect("activated", self, "_on_PushnBox2D_activated")
			_push_box_by_id.erase(id)
			property_list_changed_notify()

	
func _on_SceneTree_node_added(node: Node) -> void:
	if node.get_parent() == self:
		if node is DetectionBox2D:
			_add_detection_box(node)
		elif node is PushBox2D:
			_add_push_box(node)
		node.connect("script_changed", self, "_on_ChildNode_script_changed", [node])


func _on_SceneTree_node_removed(node: Node) -> void:
	if node.get_parent() == self:
		print("hmm")
		if node is DetectionBox2D:
			_remove_detection_box(node)
		elif node is PushBox2D:
			_remove_push_box(node)
		node.disconnect("script_changed", self, "_on_ChildNode_script_changed")


func _on_SceneTree_node_renamed(node: Node) -> void:
	if node.get_parent() == self:
		pass


func _on_ChildNode_script_changed(node: Node) -> void:
	_remove_detection_box(node)
	_remove_push_box(node)

	if node is DetectionBox2D:
		_add_detection_box(node)
	elif node is PushBox2D:
		_add_push_box(node)


func _on_DetectionBox2D_activated(activated_detection_box: DetectionBox2D) -> void:
	emit_signal("box_activated")
	for node in _detection_box_by_id.values():
		var detection_box := node as DetectionBox2D
		if detection_box != activated_detection_box:
			detection_box.is_active = false

func _on_PushBox2D_activated(activated_push_box: PushBox2D) -> void:
	emit_signal("box_activated")
	for node in _push_box_by_id.values():
		var push_box := node as PushBox2D
		if push_box != activated_push_box:
			push_box.is_active = false


