extends "input_data.gd"

func _init(input_id: int = -1, is_activated_on_release: bool = false) -> void:
    self.input_id = input_id
    self.is_activated_on_release = is_activated_on_release

var input_id: int
var is_activated_on_release: bool