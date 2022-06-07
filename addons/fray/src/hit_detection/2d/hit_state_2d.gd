tool
extends Node2D
## Node used to contain a configuration of IHitboxs
##
## @desc:
## 		This node is intended to represent a single state of a combatant such as a fighting move.
##
##		IHitbox is a pseudo interface, see interface script.
##		It is implemented by Hitboxes, HitboxSwitchers, and Pushboxes

signal activated()
signal hit_detected(hitbox)

#enums

const ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const SignalUtils = preload("res://addons/fray/lib/helpers/utils/signal_utils.gd")
const Hitbox2D = preload("hitbox_2d.gd")
const HitboxSwitcher2D = preload("hitbox_switcher_2d.gd")

#preloaded scripts and scenes

export var is_active: bool setget set_is_active

#public variables

var _cc_detector: ChildChangeDetector
#onready variables


func _init() -> void:
	FrayInterface.assert_implements(self, "IHitDetector")

#built-in virtual _ready method

func _enter_tree() -> void:
	_cc_detector = ChildChangeDetector.new(self)
	_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func deactivate() -> void:
	hide()
	for child in get_children():
		if FrayInterface.implements(child, "IHitbox"):
			child.deactivate()


func set_hitbox_source(source: Object) -> void:
	for child in get_children():
		if FrayInterface.implements(child, "IHitbox"):
			child.set_source(source)


func set_is_active(value: bool) -> void:
	is_active = value

	if is_active:
		show()
		emit_signal("activated")


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	match change:
		ChildChangeDetector.Change.ADDED, ChildChangeDetector.Change.SCRIPT_CHANGED:
			if FrayInterface.implements(node, "IHitbox"):
				SignalUtils.safe_connect(node, "activated", self, "_on_IHitbox_activated", [node])

			if FrayInterface.implements(node, "IHitDetector"):
				SignalUtils.safe_connect(node, "hit_detected", self, "_on_IHitDetector_activated")


func _on_IHitbox_activated(node: Node) -> void:
	show()
	emit_signal("activated")


func _on_IHitDetector_activated(hitbox: Hitbox2D) -> void:
	emit_signal("hit_detected", hitbox)


#inner classes
