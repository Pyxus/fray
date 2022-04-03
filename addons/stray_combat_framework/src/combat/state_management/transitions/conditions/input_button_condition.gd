extends "input_condition.gd"

const DetectedInputButton = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input_button.gd")

export var input_id: int
export var is_triggered_on_release: bool


func _init(input_id: int = -1, is_triggered_on_release: bool = false) -> void:
	self.input_id = input_id
	self.is_triggered_on_release = is_triggered_on_release


func is_satisfied_by(detected_input: DetectedInput) -> bool:
	if detected_input is DetectedInputButton:
		return detected_input.input_id == input_id and detected_input.is_pressed != is_triggered_on_release

	return false