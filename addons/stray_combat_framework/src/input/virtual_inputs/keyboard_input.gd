extends "virtual_input.gd"

var key: int

func keys() -> bool:
    return Input.is_key_pressed(key)