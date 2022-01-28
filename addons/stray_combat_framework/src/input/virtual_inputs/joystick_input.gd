extends "virtual_input.gd"

var device: int
var button: int


func is_pressed() -> bool:
    return Input.is_joy_button_pressed(device, button)