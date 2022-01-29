extends "input_data.gd"

export var input_id: int
export var is_activated_on_release: bool

func _init(input_id: int = -1, is_activated_on_release: bool = false) -> void:
	self.input_id = input_id
	self.is_activated_on_release = is_activated_on_release
