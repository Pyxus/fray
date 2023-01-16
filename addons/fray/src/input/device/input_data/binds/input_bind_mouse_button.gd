@tool
extends "input_bind_simple.gd"
## Mouse input bind

## The mouse button identifier, one of the ButtonList buttons or button wheel constants.
@export var button: int

func _init(mouse_button: int = -1) -> void:
	button = mouse_button


func _is_pressed_impl(_device: int = 0) -> bool:
	return Input.is_mouse_button_pressed(button)


func _equals_impl(input_bind: Resource) -> bool:
	return (
		super(input_bind)
		and button == input_bind.button)
