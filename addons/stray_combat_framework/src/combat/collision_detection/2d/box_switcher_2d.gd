tool
extends Node2D
## Node capable of switching between its HitBox2D and PushBox2D children.
##
## Only one HitBox2D or PushBox2D in a switcher can be active at a time.
## This node is intended to be used when animating by keying the active hitbox.

#inner classes

signal box_activated()
signal active_box_set()

#enums

const NONE = -1

const ReverseableDictionary = preload("res://addons/stray_combat_framework/lib/reversable_dictionary.gd")
const ChildChangeDetector = preload("res://addons/stray_combat_framework/lib/child_change_detector.gd")

const HitBox2D = preload("hit_box_2d.gd")
const PushBox2D = preload("body/push_box_2d.gd")

#exported variables

var active_box: int setget set_active_box
var boxes_belong_to: Object setget set_boxes_belong_to

var _cc_detector: ChildChangeDetector
var _hit_box_by_id := ReverseableDictionary.new()
var _push_box_by_id := ReverseableDictionary.new()

#onready variables


func _ready() -> void:
	set_active_box(active_box)


func _enter_tree() -> void:
	_cc_detector = ChildChangeDetector.new(self)
	_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func _get_configuration_warning() -> String:
	if _hit_box_by_id.empty() and _push_box_by_id.empty():
		return "This node is expected to have HitBox2Ds or PushBox2Ds children."
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
	for hit_box in _hit_box_by_id.values():
		hit_box.is_active = false
	for push_box in _push_box_by_id.values():
		push_box.is_active = false
	active_box = NONE


func set_boxes_belong_to(obj: Object) -> void:
	for hit_box in _hit_box_by_id.values():
		hit_box.belongs_to = obj
	for push_box in _push_box_by_id.values():
		push_box.belongs_to = obj


func set_active_box(value: int) -> void:
	active_box = value

	if is_inside_tree():
		emit_signal("active_box_set")

		if active_box == NONE:
			deactivate_all_boxes()
			return
			
		if _hit_box_by_id.has_key(active_box):
			_hit_box_by_id.get_value(active_box).is_active = true			
		elif _push_box_by_id.has_key(active_box):
			_push_box_by_id.get_value(active_box).is_active = true
		else:
			push_warning("Failed to set active box. Active box with given id `%s` does not exist in switcher" % [active_box])


func  get_hit_box_id(hit_box: HitBox2D) -> int:
	return _hit_box_by_id.get_key(hit_box, NONE)


func  get_push_box_id(push_box: PushBox2D) -> int:
	return _push_box_by_id.get_key(push_box, NONE)


func get_box_names() -> PoolStringArray:
	var array := PoolStringArray()
	array.append("[None]:%d" % NONE)

	for child in get_children():
		if child is HitBox2D:
			array.append("%s:%s" % [child.name, get_hit_box_id(child)])
		elif child is PushBox2D:
			array.append("%s:%s" % [child.name, get_push_box_id(child)])

	return array


func _gen_box_id() -> int:
	var id := 0
	while _hit_box_by_id.has_key(id) or _push_box_by_id.has_key(id):
		id += 1
	return id


func _add_box(box: Node) -> void:
	if box is HitBox2D:
		if not _hit_box_by_id.has_value(box):
			var box_id := _gen_box_id()
			_hit_box_by_id.add(box_id, box)
			box.connect("activated", self, "_on_HitBox2D_activated", [box])
			property_list_changed_notify()
	elif box is PushBox2D:
		if not _push_box_by_id.has_value(box):
			var box_id := _gen_box_id()
			_hit_box_by_id.add(box_id, box)
			box.connect("activated", self, "_on_PushBox2D_actiavted", [box])
			property_list_changed_notify()


func _remove_box(box: Node) -> void:
	if box is HitBox2D:
		if _hit_box_by_id.erase_value(box):
			if box.is_connected("activated", self, "_on_HitBox2D_activated"):
				box.disconnect("activated", self, "_on_HitBox2D_activated")
			property_list_changed_notify()
	elif box is PushBox2D:
		if _push_box_by_id.erase_value(box):
			if box.is_connected("activated", self, "_on_PushBox2D_activated"):
				box.disconnect("activated", self, "_on_PushnBox2D_activated")
			property_list_changed_notify()


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	match change:
		ChildChangeDetector.Change.ADDED:
			_add_box(node)

		ChildChangeDetector.Change.REMOVED:
			_remove_box(node)

		ChildChangeDetector.Change.RENAMED:
			property_list_changed_notify()

		ChildChangeDetector.Change.SCRIPT_CHANGED:
			_remove_box(node)
			_add_box(node)


func _on_HitBox2D_activated(activated_hit_box: HitBox2D) -> void:
	emit_signal("box_activated")
	for node in _hit_box_by_id.values():
		if node != activated_hit_box:
			node.is_active = false


func _on_PushBox2D_activated(activated_push_box: PushBox2D) -> void:
	emit_signal("box_activated")
	for node in _push_box_by_id.values():
		var push_box := node as PushBox2D
		if push_box != activated_push_box:
			push_box.is_active = false


