
tool
extends Node2D
## docstring

#inner classes

signal box_activated()
signal active_box_set()

#enums

const NONE_ACTIVE := "[None]"
const NONE = 0

const DetectionBox2D = preload("../hit_detection/detection_box_2d.gd")
const PushBox2D = preload("../body/push_box_2d.gd")

#exported variables
enum Test {
	a = 1,
	b = 1,
}
export(Test) var test2
var active_box: int setget set_active_box
var boxes_belong_to: Object setget set_boxes_belong_to

var _detection_box_by_id: Dictionary
var _push_box_by_id: Dictionary
var _box_names: PoolStringArray

#onready variables

func _ready() -> void:
	_detect_boxes()
	print(_detection_box_by_id)
	print(_push_box_by_id)
	var tree := get_tree()
	tree.connect("tree_changed", self, "_on_SceneTree_changed")


func _get_configuration_warning() -> String:
	if _detection_box_by_id.empty() and _push_box_by_id.empty():
		return "This node is expected to have DetectionBox2Ds or PushBox2Ds children."
	if not _push_box_by_id.empty() and not boxes_belong_to is RigidBody2D:
		return "PushBox2Ds are expected to belong to a RigidBody2D"
	return ""

func _get_property_list() -> Array:
	var properties: Array = []

	properties.append({
	"name": "active_box",
	"type": TYPE_INT,
	"usage": PROPERTY_USAGE_DEFAULT,
	"hint": PROPERTY_HINT_ENUM,
	"hint_string": _box_names.join(" ,")
	})
	properties.append({
		"name": "test",
		"type": TYPE_DICTIONARY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _box_names.join(" ,")
		})
	return properties

func has_active_box() -> bool:
	for detection_box in _detection_box_by_id.values():
		if detection_box.is_active:
			return true
	for push_box in _push_box_by_id.values():
		if push_box.is_active:
			return true
	return false

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

func set_active_box(value: int, notify_set: bool = true) -> void:
	active_box = value
	if is_inside_tree():
		if notify_set:
			emit_signal("active_box_set")
		if active_box != NONE:
			if _detection_box_by_id.has(active_box - 1):
				_detection_box_by_id[active_box - 1].is_active = true
			elif _push_box_by_id.has(active_box - 1):
				_push_box_by_id[active_box - 1].is_active = true
			else:
				print(active_box)
				push_error("Active box value does not correspond to any dictionary")
		else:
			deactivate_all_boxes()

func _gen_box_id() -> int:
	# Why am I doing this again? I could have just done an incrementing id...
	var id := 1
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
	_box_names = [NONE_ACTIVE]

	var detected_detection_boxes: Array
	var detected_push_boxes: Array

	for child in get_children():
		if child is DetectionBox2D:
			_box_names.append(child.name)
			detected_detection_boxes.append(child)

			if id_by_detection_box.has(child):
				var box_id: int = id_by_detection_box[child]
				_detection_box_by_id[box_id] = child

			if not child.is_connected("activated", self, "_on_DetectionBox_activated"):
				child.connect("activated", self, "_on_DetectionBox_activated", [child])
		elif child is PushBox2D:
			_box_names.append(child.name)
			detected_detection_boxes.append(child)

			if id_by_push_box.has(child):
				var box_id: int = id_by_push_box[child]
				_push_box_by_id[box_id] = child

			if not child.is_connected("activated", self, "_on_PushBox_activated"):
				child.connect("activated", self, "_on_PushBox_activated", [child])

	for detection_box in detected_detection_boxes:
		if not id_by_detection_box.has(detection_box):
			_detection_box_by_id[_gen_box_id()] = detection_box

	for push_box in detected_push_boxes:
		if not id_by_push_box.has(push_box):
			_push_box_by_id[_gen_box_id()] = push_box


	property_list_changed_notify()
	update_configuration_warning()

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
