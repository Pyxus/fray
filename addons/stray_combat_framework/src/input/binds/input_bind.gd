extends Resource

var _previously_pressed: bool

func poll() -> void:
	if is_pressed():
		if not _previously_pressed:
			_previously_pressed = true
	else:
		_previously_pressed = false

func is_pressed() -> bool:
	return false

func is_just_pressed() -> bool:
	return is_pressed() and not _previously_pressed

func is_just_released() -> bool:
	return not is_pressed() and _previously_pressed
