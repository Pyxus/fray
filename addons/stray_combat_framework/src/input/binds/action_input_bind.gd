extends "input_bind.gd"

var action: String


func is_pressed() -> bool:
	return Input.is_action_pressed(action)
