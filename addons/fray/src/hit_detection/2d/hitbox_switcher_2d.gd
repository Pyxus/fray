tool
extends Node2D
## Node capable of switching between IHitboxes.
## @desc:
## 		Only one IHitbox in switcher can be activated at a time.
## 		This node is intended to be used when animating by keying the active hitbox.
##
##		IHitbox is a pseudo interface, see interface script.
##		It is implemented by Hitboxes, HitboxSwitchers, and Pushboxes

const ChildChangeDetector = preload("res://addons/fray/lib/helpers/child_change_detector.gd")
const SignalUtils = preload("res://addons/fray/lib/helpers/utils/signal_utils.gd")
const Hitbox2D = preload("hitbox_2d.gd")

signal hit_detected(hitbox)
signal activated()

#enums

const NONE = ":None:"

#preloaded scripts and scenes

var active_hitbox: String setget set_active_hitbox

#public variables

var _cc_detector: ChildChangeDetector
var _current_hitbox: Object

#onready variables


func _init() -> void:
	FrayInterface.assert_implements(self, "IHitbox")
	FrayInterface.assert_implements(self, "IHitDetector")
	push_warning("Deprecated Class")

#built-in virtual _ready method

func _enter_tree() -> void:
	_cc_detector = ChildChangeDetector.new(self)
	_cc_detector.connect("child_changed", self, "_on_ChildChangeDetector_child_changed")


func set_active_hitbox(value: String) -> void:
	active_hitbox = value

	if is_inside_tree():
		if active_hitbox != NONE:
			var hitbox = get_node_or_null(value)

			if not FrayInterface.implements(hitbox, "IHitbox"):
				push_error("Fail to switch active hitbox. Hitbox child with name '%s' could not be found or does not implement IHitbox" % value)
				return

			_current_hitbox = hitbox
			hitbox.activate()
			emit_signal("activated")
			show()
		else:
			_current_hitbox = null

		for child in get_children():
			if child != _current_hitbox and FrayInterface.implements(child, "IHitbox"):
				child.deactivate()


func set_source(hitbox_source: Object) -> void:
	for child in get_children():
		if FrayInterface.implements(child, "IHitbox"):
			child.set_source(hitbox_source)


func deactivate() -> void:
	hide()
	set_active_hitbox(NONE)


func _get_property_list() -> Array:
	var properties: Array = []
	var hitbox_names: PoolStringArray = [NONE]
	
	for child in get_children():
		if FrayInterface.implements(child, "IHitbox"):
			hitbox_names.append(child.name)
	
	properties.append({
		"name": "active_hitbox",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": hitbox_names.join(",")
	})
	
	return properties


func _on_ChildChangeDetector_child_changed(node: Node, change: int) -> void:
	property_list_changed_notify()
	match change:
		ChildChangeDetector.Change.ADDED, ChildChangeDetector.Change.SCRIPT_CHANGED:
			if FrayInterface.implements(node, "IHitbox"):
				SignalUtils.safe_connect(node, "activated", self, "_on_IHitbox_activated", [node])
			
			if FrayInterface.implements(node, "IHitDetector"):
				SignalUtils.safe_connect(node, "hit_detected", self, "_on_IHitDetector_activated")


func _on_IHitbox_activated(i_hitbox: Object) -> void:
	emit_signal("activated")
	if i_hitbox != _current_hitbox:
		i_hitbox.deactivate()


func _on_IHitDetector_activated(hitbox: Hitbox2D) -> void:
	emit_signal("hit_detected", hitbox)


#inner classes
