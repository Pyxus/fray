extends "input_condition.gd"
## Class representing input button condition

const BufferedInputButton = preload("../../buffered_input/buffered_input_button.gd")

## Input id
export var input_id: int


func _init(input_id: int = -1) -> void:
	self.input_id = input_id


func is_satisfied_by(buffered_input: BufferedInput) -> bool:
	if buffered_input is BufferedInputButton:
		return buffered_input.id == input_id

	return false
