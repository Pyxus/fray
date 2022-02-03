extends "input_data.gd"

var VirtualInputData = load("res://addons/stray_combat_framework/src/combat/fsm_states/input_data/virtual_input_data.gd")

export var input_id: int
export var is_activated_on_release: bool

func _init(input_id: int = -1, is_activated_on_release: bool = false) -> void:
	self.input_id = input_id
	self.is_activated_on_release = is_activated_on_release


func equals(input_data: Reference) -> bool:
	.equals(input_data)
	if input_data is VirtualInputData:
		return input_data.input_id == input_id and input_data.is_activated_on_release == is_activated_on_release
	return false
