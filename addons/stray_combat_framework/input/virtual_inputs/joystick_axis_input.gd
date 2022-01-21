extends "virtual_input.gd"

var device: int
var axis: int
var deadzone: float setget set_deadzone


func is_pressed() -> bool:
    return Input.get_joy_axis(device, axis) >= deadzone

func set_deadzone(value: float) -> void:
    deadzone = clamp(value, 0, 1)