extends "condition_input.gd"
## Condition that is satisfied by buffered input seqeunce

const BufferedInputSequence = preload("../../buffered_input/buffered_input_sequence.gd")

var sequence_name: String

func _equals_impl(condition: Reference) -> bool:
    return ._equals_impl(condition) and sequence_name == condition.sequence_name 


func _is_satisfied_impl() -> bool:
    var buffered_input := _get_buffered_input() as BufferedInputSequence
    if buffered_input == null:
        return false

    return ._is_satisfied_impl() and buffered_input.sequence_name == sequence_name