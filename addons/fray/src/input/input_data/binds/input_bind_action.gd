tool
extends "input_bind.gd"
## Action input bind
##
## @desc:
##		Bind that makes use of godot's actions

## Action name
var action: String


func _init(action_name: String = "") -> void:
	action = action_name


func _is_pressed_impl(device: int = 0) -> bool:
	if not InputMap.has_action(action):
		push_warning("Action '%s' does not exist in Godot InputMap" % action)
		return false
	return Input.is_action_pressed(action)
