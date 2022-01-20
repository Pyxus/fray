extends Reference

var device: int
var action: String
var time_stamp: int
var time_held: float
var _is_released: bool = false

func increment_held_time(increment: float) -> void:
    if not _is_released:
        if Input.is_action_pressed(action):
            time_held += increment
        elif Input.is_action_just_released(action):
            _is_released = true

func is_released() -> bool:
    return _is_released