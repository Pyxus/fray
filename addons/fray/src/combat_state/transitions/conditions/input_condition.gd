extends Resource
## Abstract Class representing input condition

const BufferedInput = preload("../../buffered_input/buffered_input.gd")

## Abstract method which returns true if the detected input satisfies this condition
func is_satisfied_by(buffered_input: BufferedInput) -> bool:
	push_error("Method not implemented.")
	return false
