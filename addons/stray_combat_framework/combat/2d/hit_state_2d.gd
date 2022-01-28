tool
extends Node2D
## Node used to contain a configuration of DetectionBox2Ds and/or PushBox2Ds.
##
## This node is intended to represent a single state of a fighter such as a fighting move.

signal animation_set
signal activated

#signals

const BoxSwitcher2D = preload("box_switcher_2d.gd")
const DetectionBox2D = preload("hit_detection/detection_box_2d.gd")
const PushBox2D = preload("body/push_box_2d.gd")

export var is_active: bool setget set_is_active

var _thread: Thread
var _detection_boxes: Array
var _push_boxes: Array
var _box_switchers: Array
var _animation_list: PoolStringArray

#onready variables

#optional built-in virtual _init method


func _ready():
	_thread = Thread.new()
	var tree := get_tree()
	tree.connect("tree_changed", self, "_on_SceneTree_changed")

func _exit_tree() -> void:
	_thread.wait_to_finish()

	
func set_animation_list(list: PoolStringArray) -> void:
	_animation_list = list
	property_list_changed_notify()


func set_is_active(value: bool) -> void:
	if is_active != value:
		if value:
			show()
			emit_signal("activated")
		else:
			hide()
			deactivate_boxes()
	is_active = value

func deactivate_boxes() -> void:
	for detection_box in _detection_boxes:
		detection_box.is_active = false

	for push_box in _push_boxes:
		push_box.is_active = false


func set_boxes_belong_to(obj: Object) -> void:
	for detection_box in _detection_boxes:
		detection_box.belongs_to = obj

	for push_box in _push_boxes:
		push_box.belongs_to = obj
	

func _detect_box_switchers() -> void:
	_box_switchers.clear()
	_detection_boxes.clear()
	_push_boxes.clear()

	for child in get_children():
		if child is BoxSwitcher2D:
			_box_switchers.append(child)
			if not child.is_connected("active_box_set", self, "_on_BoxSwitcher_active_box_set"):
				child.connect("active_box_set", self, "_on_BoxSwitcher_active_box_set")
		elif child is DetectionBox2D:
			_detection_boxes.append(child)
			if not child.is_connected("activated", self, "_on_DetectionBox2D_activated"):
				child.connect("activated", self, "_on_DetectionBox2D_activated")
		elif child is PushBox2D:
			_push_boxes.append(child)
			if not child.is_connected("activated", self, "_on_PushBox2D_activated"):
				child.connect("activated", self, "_on_PushBox2D_activated")


func _on_SceneTree_changed() -> void:
	if Engine.editor_hint:
		if not _thread.is_active():
			_thread.start(self, "_detect_box_switchers")


func _on_DetectionBox2D_activated() -> void:
	set_is_active(true)


func _on_PushBox2D_activated() -> void:
	set_is_active(true)


func _on_BoxSwitcher_active_box_set() -> void:
	set_is_active(true)
