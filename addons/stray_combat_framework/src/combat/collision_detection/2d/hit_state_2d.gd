tool
extends Node2D
## Node used to contain a configuration of HitBox2Ds and/or PushBox2Ds.
##
## This node is intended to represent a single state of a fighter such as a fighting move.

signal animation_set()
signal activated()

#signals

const ChildChangeDetector = preload("res://addons/stray_combat_framework/lib/helpers/child_change_detector.gd")

const BoxSwitcher2D = preload("box_switcher_2d.gd")
const HitBox2D = preload("hit_box_2d.gd")
const RigidPushBox2D = preload("body/rigid_push_box_2d.gd")

export var is_active: bool setget set_is_active

var _cc_detector: ChildChangeDetector

#onready variables

#optional built-in virtual _init method


func _enter_tree() -> void:
	_cc_detector = ChildChangeDetector.new(self)
	_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


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
	for child in get_children():
		if child is HitBox2D or child is RigidPushBox2D:
			child.is_active = false


func set_boxes_belong_to(obj: Object) -> void:
	for child in get_children():
		if child is HitBox2D or child is RigidPushBox2D:
			child.belongs_to = obj


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	match change:
		ChildChangeDetector.Change.ADDED:
			if node is BoxSwitcher2D:
				if not node.is_connected("active_box_set", self, "_on_BoxSwitcher_active_box_set"):
					node.connect("active_box_set", self, "_on_BoxSwitcher_active_box_set")
			elif node is HitBox2D:
				if not node.is_connected("activated", self, "_on_HitBox2D_activated"):
					node.connect("activated", self, "_on_HitBox2D_activated")
			elif node is RigidPushBox2D:
				if not node.is_connected("activated", self, "_on_PushBox2D_activated"):
					node.connect("activated", self, "_on_PushBox2D_activated")

		ChildChangeDetector.Change.REMOVED:
			if node is BoxSwitcher2D:
				if node.is_connected("active_box_set", self, "_on_BoxSwitcher_active_box_set"):
					node.disconnect("active_box_set", self, "_on_BoxSwitcher_active_box_set")
			elif node is HitBox2D:
				if node.is_connected("activated", self, "_on_HitBox2D_activated"):
					node.disconnect("activated", self, "_on_HitBox2D_activated")
			elif node is RigidPushBox2D:
				if node.is_connected("activated", self, "_on_PushBox2D_activated"):
					node.disconnect("activated", self, "_on_PushBox2D_activated")


func _on_HitBox2D_activated() -> void:
	set_is_active(true)


func _on_PushBox2D_activated() -> void:
	set_is_active(true)


func _on_BoxSwitcher_active_box_set() -> void:
	set_is_active(true)
