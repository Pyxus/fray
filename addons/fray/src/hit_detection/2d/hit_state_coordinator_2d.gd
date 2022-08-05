tool
extends Node2D
## Node used to coordinate HitState2D children
## 
## @desc:
##		When a HitState2D child is activated all others will be deactivate.
##		This is a convinience tool for enforcing discrete hit states.

const HitState2D = preload("hit_state_2d.gd")
const Hitbox2D = preload("hitbox_2d.gd")
const ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const SignalUtils = preload("res://addons/fray/lib/helpers/utils/signal_utils.gd")

signal hit_detected(hitbox)

#enums

#constants

#preloaded scripts and scenes

export var hitbox_source: NodePath setget set_hitbox_source

#public variables

var _cc_detector: ChildChangeDetector
var _current_hit_state: HitState2D

#onready variables


func _init() -> void:
	FrayInterface.assert_implements(self, "IHitDetector")
	push_warning("Deprecated Class")

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

## Returns the current activated hit state
func get_current_hit_state() -> HitState2D:
	return _current_hit_state


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	match change:
		ChildChangeDetector.Change.ADDED, ChildChangeDetector.Change.SCRIPT_CHANGED:
			if node is HitState2D:
				SignalUtils.safe_connect(node, "activated", self, "_on_Hitstate2D_activated", [node])

			if FrayInterface.implements(node, "IHitDetector"):
				SignalUtils.safe_connect(node, "hit_detected", self, "_on_IHitDetector_activated")
					

func _on_Hitstate2D_activated(node: Node) -> void:
	for child in get_children():
		if child != node:
			child.deactivate()


func _on_IHitDetector_activated(hitbox: Hitbox2D) -> void:
	emit_signal("hit_detected", hitbox)
