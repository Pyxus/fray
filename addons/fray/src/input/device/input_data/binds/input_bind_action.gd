@tool
extends "input_bind_simple.gd"
## Action input bind
##
## @desc:
##		Bind that makes use of godot's actions

## Action name
var action: String


func _init(action_name: String = "") -> void:
	action = action_name


func _is_pressed_impl(_device: int = 0) -> bool:
	if not InputMap.has_action(action):
		push_warning("Action '%s' does not exist in Godot InputMap" % action)
		return false
	return Input.is_action_pressed(action)


func _equals_impl(input_bind: Resource) -> bool:
	return (
		super(input_bind)
		and action == input_bind.action)


func _get_strength_impl(_device: int = 0) -> float:
	return Input.get_action_strength(action)
