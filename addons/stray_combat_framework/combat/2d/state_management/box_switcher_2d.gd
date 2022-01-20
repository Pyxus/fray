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

const DetectionBox2D = preload("../hit_detection/detection_box_2d.gd")
const PushBox2D = preload("../body/push_box_2d.gd")

#exported variables

var active_box: int setget set_active_box
var boxes_belong_to: Object setget set_boxes_belong_to

var _detection_box_by_id: Dictionary
var _push_box_by_id: Dictionary
var _box_names: PoolStringArray

#onready variables

func _ready() -> void:
	var tree := get_tree()
	tree.connect("tree_changed", self, "_on_SceneTree_changed")
	
	_detect_boxes()
	set_active_box(active_box)

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
	"hint_string": _box_names.join(" ,")
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

func _gen_box_id() -> int:
	var id := 0
	while _detection_box_by_id.has(id) or _push_box_by_id.has(id):
		id += 1
	return id

func _detect_boxes() -> void:
	# Map object to id. Used to remap id to same object to help preserve animation keys.
	var id_by_detection_box: Dictionary
	var id_by_push_box: Dictionary

	for key in _detection_box_by_id:
		var d_box: DetectionBox2D = _detection_box_by_id[key]
		id_by_detection_box[d_box] = key
	
	for key in _push_box_by_id:
		var p_box: DetectionBox2D = _push_box_by_id[key]
		id_by_detection_box[p_box] = key

	_detection_box_by_id.clear()
	_push_box_by_id.clear()
	_box_names = ["[None]:%s" % NONE]

	var detected_detection_boxes: Array
	var detected_push_boxes: Array

	for child in get_children():
		if child is DetectionBox2D:
			detected_detection_boxes.append(child)

			if id_by_detection_box.has(child):
				var box_id: int = id_by_detection_box[child]
				_detection_box_by_id[box_id] = child
				_box_names.append("%s:%s" % [child.name, box_id])

			if not child.is_connected("activated", self, "_on_DetectionBox_activated"):
				child.connect("activated", self, "_on_DetectionBox_activated", [child])
		elif child is PushBox2D:
			detected_detection_boxes.append(child)

			if id_by_push_box.has(child):
				var box_id: int = id_by_push_box[child]
				_push_box_by_id[box_id] = child
				_box_names.append("%s:%s" % [child.name, box_id])

			if not child.is_connected("activated", self, "_on_PushBox_activated"):
				child.connect("activated", self, "_on_PushBox_activated", [child])

	for detection_box in detected_detection_boxes:
		if not id_by_detection_box.has(detection_box):
			var box_id := _gen_box_id()
			_detection_box_by_id[box_id] = detection_box
			_box_names.append("%s:%s" % [detection_box.name, box_id])

	for push_box in detected_push_boxes:
		if not id_by_push_box.has(push_box):
			var box_id := _gen_box_id()
			_push_box_by_id[_gen_box_id()] = push_box
			_box_names.append("%s:%s" % [push_box.name, box_id])

	property_list_changed_notify()
	#update_configuration_warning()

func _on_SceneTree_changed() -> void:
	if Engine.editor_hint:
		_detect_boxes()

func _on_DetectionBox_activated(activated_detection_box: DetectionBox2D) -> void:
	emit_signal("box_activated")
	for node in _detection_box_by_id.values():
		var detection_box := node as DetectionBox2D
		if detection_box != activated_detection_box:
			detection_box.is_active = false

func _on_PushBox_activated(activated_push_box: PushBox2D) -> void:
	emit_signal("box_activated")
	for node in _push_box_by_id.values():
		var push_box := node as PushBox2D
		if push_box != activated_push_box:
			push_box.is_active = false
