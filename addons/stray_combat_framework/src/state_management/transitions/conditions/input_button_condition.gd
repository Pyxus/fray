extends "input_condition.gd"
## Class representing input button condition

# Imports
const BufferedInputButton = preload("../../buffered_input/buffered_input_button.gd")

## Input id
export var input_id: int

## If true the condition only counts the input if it is released
export var is_triggered_on_release: bool #TODO: Reimplement, currently this condition is ignored by the only analyzer implementation


func _init(input_id: int = -1, is_triggered_on_release: bool = false) -> void:
	self.input_id = input_id
	self.is_triggered_on_release = is_triggered_on_release


func is_satisfied_by(buffered_input: BufferedInput) -> bool:
	if buffered_input is BufferedInputButton:
		return buffered_input.id == input_id and buffered_input.is_pressed != is_triggered_on_release

	return false
