extends "input_bind.gd"
## Action input bind
##
## @desc:
##		This bind makes use of godot's action map

## Action name
var action: String

func _init(action_name: String = "") -> void:
	action = action_name

func is_pressed(device: int = 0) -> bool:
	return Input.is_action_pressed(action)
