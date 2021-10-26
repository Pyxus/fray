
tool
extends Node2D
## docstring

#inner classes

signal box_activated()
signal active_box_set()

#enums

const NONE = 0

const DetectionBox2D = preload("../hit_detection/detection_box_2d.gd")
const PushBox2D = preload("../body/push_box_2d.gd")

#exported variables

var active_box: int setget set_active_box
var boxes_belong_to: Object setget set_boxes_belong_to

var _detection_boxes: Array = []
var _push_boxes: Array = []
var _detection_box_by_id: Dictionary
var _push_box_by_id: Dictionary
var _prev_box_count: int = 0
var _box_names: PoolStringArray = ["[None]"]

#onready variables


func _init() -> void:
	if is_inside_tree():
		_detect_boxes()

func _ready() -> void:
	_detect_boxes()
	set_active_box(active_box)

func _process(delta: float) -> void:
	if Engine.editor_hint:
		var box_count := _get_box_count()
		if _detection_boxes.empty() and _push_boxes.empty() or _prev_box_count != box_count:
			_detect_boxes()
		else:
			for detection_box in _detection_boxes:
				if not detection_box is DetectionBox2D:
					_detect_boxes()
					break

			for push_box in _push_boxes:
				if not push_box is PushBox2D:
					_detect_boxes()
					break
		_prev_box_count = box_count

func _get_configuration_warning() -> String:
	if _detection_boxes.empty() and _push_boxes.empty():
		return "This node is expected to have DetectionBox2Ds or PushBox2Ds children."
	if not _push_boxes.empty() and not boxes_belong_to is RigidBody2D:
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
	return properties

func has_active_box() -> bool:
	for detection_box in _detection_boxes:
		if detection_box.is_active:
			return true
	for push_box in _push_boxes:
		if push_box.is_active:
			return true
	return false

func deactivate_all_boxes() -> void:
	for detection_box in _detection_boxes:
		detection_box.is_active = false
	for push_box in _push_boxes:
		push_box.is_active = false
	active_box = NONE

func set_boxes_belong_to(obj: Object) -> void:
	for detection_box in _detection_boxes:
		detection_box.belongs_to = obj
	for push_box in _push_boxes:
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
				push_error("Active box value does not correspond to any dictionary")
		else:
			deactivate_all_boxes()


func _detect_boxes() -> void:
	_push_boxes.clear()
	_detection_boxes.clear()
	_detection_box_by_id.clear()
	_push_box_by_id.clear()
	_box_names = ["[None]"]

	var i: int = 0
	for child in get_children():
		if child is DetectionBox2D:
			_detection_boxes.append(child)
			_box_names.append(child.name)
			_detection_box_by_id[i] = child
			i += 1

			if not child.is_connected("activated", self, "_on_DetectionBox_activated"):
				child.connect("activated", self, "_on_DetectionBox_activated", [child])
		elif child is PushBox2D:
			_push_boxes.append(child)
			_box_names.append(child.name)
			_push_box_by_id[i] = child
			i += 1

			if not child.is_connected("activated", self, "_on_PushBox_activated"):
				child.connect("activated", self, "_on_PushBox_activated", [child])

	property_list_changed_notify()
	update_configuration_warning()

func _get_box_count() -> int:
	var count := 0
	for child in get_children():
		if child is PushBox2D or child is DetectionBox2D:
			count += 1
	return count

func _on_DetectionBox_activated(activated_detection_box: DetectionBox2D) -> void:
	emit_signal("box_activated")
	for node in _detection_boxes:
		var detection_box := node as DetectionBox2D
		if detection_box != activated_detection_box:
			detection_box.is_active = false

func _on_PushBox_activated(activated_push_box: PushBox2D) -> void:
	emit_signal("box_activated")
	for node in _detection_boxes:
		var push_box := node as PushBox2D
		if push_box != activated_push_box:
			push_box.is_active = false