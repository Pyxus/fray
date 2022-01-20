extends "simple_input.gd"

var button: int

func is_pressed() -> bool:
    return Input.is_mouse_button_pressed(button)