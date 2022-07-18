extends "input_bind.gd"
## Keyboard input bind

## The key scancode, which corresponds to one of the KeyList constants.
export var key: int

func _init(keyboard_key: int = -1) -> void:
	key = keyboard_key

	
func is_pressed(device: int = 0) -> bool:
	return Input.is_key_pressed(key)
