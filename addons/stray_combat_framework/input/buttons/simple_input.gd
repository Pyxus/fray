extends Reference

var previously_pressed: bool

func poll() -> void:
    if is_pressed():
        if not previously_pressed:
            previously_pressed = true
    else:
        previously_pressed = false

func is_pressed() -> bool:
    return false

func is_just_pressed() -> bool:
    return is_pressed() and not previously_pressed

func is_just_released() -> bool:
    return not is_pressed() and previously_pressed

func is_combination() -> bool:
    return false