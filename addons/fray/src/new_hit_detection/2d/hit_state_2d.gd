tool
extends Node2D
## docstring

signal activated()

#enums

const ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const SignalUtils = preload("res://addons/fray/lib/helpers/utils/signal_utils.gd")
const Hitbox2D = preload("hitbox_2d.gd")
const HitboxSwitcher2D = preload("hitbox_switcher_2d.gd")

#preloaded scripts and scenes

#exported variables

#public variables

var _cc_detector: ChildChangeDetector
#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

func _enter_tree() -> void:
	_cc_detector = ChildChangeDetector.new(self)
	_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func deactivate() -> void:
	hide()
	for child in get_children():
		if FrayInterface.implements_IHitbox(child):
			child.deactivate()


func set_hitbox_source(source: Object) -> void:
	for child in get_children():
		if FrayInterface.implements_IHitbox(child):
			child.set_source(source)


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	match change:
		ChildChangeDetector.Change.ADDED:
			if FrayInterface.implements_IHitbox(node):
				SignalUtils.safe_connect(node, "activated", self, "_on_IHitbox_activated", [node])

		ChildChangeDetector.Change.REMOVED:
			if FrayInterface.implements_IHitbox(node):
				SignalUtils.safe_disconnect(node, "activated", self, "_on_IHitbox_activated")

		ChildChangeDetector.Change.SCRIPT_CHANGED:
			if FrayInterface.implements_IHitbox(node):
				SignalUtils.safe_connect(node, "activated", self, "_on_IHitbox_activated", [node])
			else:
				SignalUtils.safe_disconnect(node, "activated", self, "_on_IHitbox_activated")


func _on_IHitbox_activated(node: Node) -> void:
	show()
	emit_signal("activated")

#inner classes
