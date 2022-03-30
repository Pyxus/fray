extends "input_condition.gd"

const DetectedVirtualInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_virtual_input.gd")

var VirtualInputCondition = load("res://addons/stray_combat_framework/src/combat/state_management/input_data/virtual_input_condition.gd")

export var input_id: int
export var is_triggered_on_release: bool


func _init(input_id: int = -1, is_triggered_on_release: bool = false) -> void:
	self.input_id = input_id
	self.is_triggered_on_release = is_triggered_on_release


func is_satisfied_by(detected_input: DetectedInput) -> bool:
	if detected_input is DetectedVirtualInput:
		return detected_input.input_id == input_id and detected_input.is_pressed != is_triggered_on_release

	return false


func equals(input_condition: Reference) -> bool:
	.equals(input_condition)
	if input_condition is VirtualInputCondition:
		return input_condition.input_id == input_id and input_condition.is_triggered_on_release == is_triggered_on_release
	
	return false
