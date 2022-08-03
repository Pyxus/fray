extends Resource
## Abstract Class representing input condition

const BufferedInput = preload("../../buffered_input/buffered_input.gd")

## Returns true if the detected input satisfies this condition
func is_satisfied_by(buffered_input: BufferedInput) -> bool:
	return _is_satisfied_by_impl(buffered_input)

## Abstract method which returns trie if the detected input satisfied this condition
func _is_satisfied_by_impl(buffered_input: BufferedInput) -> bool:
	push_error("Method not implemented.")
	return false