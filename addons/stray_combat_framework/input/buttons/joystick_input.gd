extends "simple_input.gd"

var device: int
var buttons: PoolIntArray


func is_pressed() -> bool:
    if buttons.empty():
        return false
        
    for button in buttons:
        if not Input.is_joy_button_pressed(device, button):
            return false
    return true

func is_combination() -> bool:
    return buttons.size() > 1