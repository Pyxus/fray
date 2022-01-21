extends Reference

var previously_pressed: bool
var id: int
var pressed_at: int = -1
var released_at: int = -1

func poll() -> void:
    if is_pressed():
        pressed_at = OS.get_ticks_msec()
        if not previously_pressed:
            previously_pressed = true
    else:
        if previously_pressed:
            released_at = OS.get_ticks_msec()
        previously_pressed = false

func is_pressed() -> bool:
    return false

func is_just_pressed() -> bool:
    return is_pressed() and not previously_pressed

func is_just_released() -> bool:
    return not is_pressed() and previously_pressed

func is_combination() -> bool:
    return false