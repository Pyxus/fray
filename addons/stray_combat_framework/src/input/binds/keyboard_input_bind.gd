extends "input_bind.gd"

export var key: int

func _init(keyboard_key: int = -1) -> void:
	key = keyboard_key

	
func keys() -> bool:
	return Input.is_key_pressed(key)
