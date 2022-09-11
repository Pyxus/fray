tool
extends "input_bind_simple.gd"
## Keyboard input bind

## The key scancode, which corresponds to one of the KeyList constants.
export var key: int

func _init(keyboard_key: int = -1) -> void:
	key = keyboard_key

	
func _is_pressed_impl(device: int = 0) -> bool:
	return Input.is_key_pressed(key)


func _equals_impl(input_bind: Resource) -> bool:
	return (
		._equals_impl(input_bind)
		and key == input_bind.key)
