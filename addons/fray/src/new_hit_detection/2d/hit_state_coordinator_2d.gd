tool
extends Node2D
## docstring

# Imports
const HitState2D = preload("hit_state_2d.gd")
const ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const SignalUtils = preload("res://addons/fray/lib/helpers/utils/signal_utils.gd")

#signals

#enums

#constants

#preloaded scripts and scenes

export var hitbox_source: NodePath setget set_hitbox_source

#public variables

var _cc_detector: ChildChangeDetector
var _current_hit_state: HitState2D

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

func _enter_tree() -> void:
	_cc_detector = ChildChangeDetector.new(self)
	_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func set_hitbox_source(value: NodePath) -> void:
	hitbox_source = value

	if is_inside_tree():
		var source_node = get_node_or_null(hitbox_source)

		for child in get_children():
			if child is HitState2D:
				child.set_hitbox_source(hitbox_source)


func get_current_hit_state() -> HitState2D:
	return _current_hit_state


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	match change:
		ChildChangeDetector.Change.ADDED:
			if node is HitState2D:
				SignalUtils.safe_connect(node, "activated", self, "_on_Hitstate2D_activated", [node])
	
		ChildChangeDetector.Change.REMOVED:
			if node is HitState2D:
				SignalUtils.safe_disconnect(node, "activated", self, "_on_Activatible_activated")
	
		ChildChangeDetector.Change.SCRIPT_CHANGED:
			if node is HitState2D:
				SignalUtils.safe_connect(node, "activated", self, "_on_Hitstate2D_activated", [node])
			else:
				SignalUtils.safe_connect(node, "activated", self, "_on_Hitstate2D_activated", [node])
					

func _on_Hitstate2D_activated(node: Node) -> void:
	for child in get_children():
		if child != node:
			child.deactivate()

#inner classes
