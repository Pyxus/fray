
tool
extends Node2D
## docstring

signal animation_set()
signal activated()
signal active_box_set()

#signals

enum FrameState {
	NEUTRAL,
	STARTUP,
	ACTIVE,
	RECOVERY,
}

const NO_ANIMATION = "[None]"

const BoxSwitcher2D = preload("box_switcher_2d.gd")

export var is_active: bool setget set_is_active
export(FrameState) var frame_state: int = FrameState.STARTUP

var animation: String setget set_animation
var transition_animation: String setget set_transition_animation
var animation_player: AnimationPlayer setget set_animation_player

var _box_switchers: Array
var _prev_switcher_count: int = 0

#onready variables


#optional built-in virtual _init method

func _ready():
	set_animation_player(animation_player)

func _process(delta: float) -> void:
	if Engine.editor_hint:
		if get_child_count() != 0:
			var switcher_count = _get_switcher_count()
			if _box_switchers.empty() or _prev_switcher_count != switcher_count:
				_detect_box_switchers()
			else:
				for box_switcher in _box_switchers:
					if not box_switcher is BoxSwitcher2D:
						_detect_box_switchers()
						break
			_prev_switcher_count = switcher_count


func _get_property_list() -> Array:
	var properties: Array = []

	var animations: PoolStringArray = [NO_ANIMATION]
	animations.append_array(animation_player.get_animation_list())

	if animation_player != null:
		properties.append({
		"name": "animation",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": animations.join(",")
		})
		properties.append({
			"name": "transision_animation",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": animations.join(",")
		})
		
	return properties

"""
func _get_configuration_warning() -> String:
	var is_switcher_found := false
	for child in _box_switchers:
		if child is BoxSwitcher2D:
			is_switcher_found = true
			break
	
	if not is_switcher_found:
		return "This node is expected to have BoxSwitcher2D children."

	return ""
"""

func set_is_active(value: bool) -> void:
	if is_active != value:
		if is_active:
			show()
			print("hmm?")
			emit_signal("activated")
		else:
			hide()
			deactivate_boxes()

	is_active = value

func deactivate_boxes() -> void:
	for child in _box_switchers:
		if child is BoxSwitcher2D:
			child.set_active_box(BoxSwitcher2D.NONE, false) # Pass this true to enjoy an editor crash via infinite signal loop :)

func set_boxes_belong_to(obj: Object) -> void:
	for child in _box_switchers:
		if child is BoxSwitcher2D:
			child.set_boxes_belong_to(obj)

func set_animation(value: String) -> void:
	animation = value.strip_edges()
	if animation != NO_ANIMATION:
		if transition_animation == animation:
			transition_animation = NO_ANIMATION
		emit_signal("animation_set")
	property_list_changed_notify()

func set_transition_animation(value: String) -> void:
	transition_animation = value.strip_edges()
	if transition_animation != NO_ANIMATION:
		if transition_animation == animation:
			push_warning("Transision animation can not be the same as animation")
			transition_animation = NO_ANIMATION
		else:
			emit_signal("animation_set")
	property_list_changed_notify()

func set_animation_player(player: AnimationPlayer) -> void:
	animation_player = player
	property_list_changed_notify()

func _detect_box_switchers() -> void:
	_box_switchers.clear()
	for child in get_children():
		if child is BoxSwitcher2D:
			_box_switchers.append(child)
			if not child.is_connected("box_activated", self, "_on_BoxSwitcher_box_activated"):
				child.connect("box_activated", self, "_on_BoxSwitcher_box_activated")
			if not child.is_connected("active_box_set", self, "_on_BoxSwitcher_active_box_set"):
				child.connect("active_box_set", self, "_on_BoxSwitcher_active_box_set")
	property_list_changed_notify()

func _get_switcher_count() -> int:
	var count := 0
	for child in get_children():
		if child is BoxSwitcher2D:
			count += 1
	return count

func _on_BoxSwitcher_box_activated() -> void:
	set_is_active(true)

func _on_BoxSwitcher_active_box_set() -> void:
	emit_signal("active_box_set")
