extends "input_bind.gd"

var action: String

func _init(action_name: String = "") -> void:
	action = action_name

func is_pressed() -> bool:
	return Input.is_action_pressed(action)
