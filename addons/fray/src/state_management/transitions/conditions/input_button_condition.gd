extends "input_condition.gd"
## Class representing input button condition

const BufferedInputButton = preload("../../buffered_input/buffered_input_button.gd")

## Input id
export var input: String

## If true the condition only counts the input if it is released
export var is_triggered_on_release: bool


func _init(input_name: String = "", is_triggered_on_release: bool = false) -> void:
	input = input_name
	self.is_triggered_on_release = is_triggered_on_release


func _is_satisfied_by_impl(buffered_input: BufferedInput) -> bool:
	if buffered_input is BufferedInputButton:
		return buffered_input.input == input and buffered_input.is_pressed != is_triggered_on_release

	return false
