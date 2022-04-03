extends "input_bind.gd"

export var key: int

func keys() -> bool:
	return Input.is_key_pressed(key)
