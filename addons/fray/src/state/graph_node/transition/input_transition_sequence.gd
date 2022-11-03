extends "input_transition.gd"

## Name of the sequence
var sequence_name: String

func _accepts_impl(sm_input: Dictionary) -> bool:
    return (
        ._accepts_impl(sm_input)
        and sequence_name == sm_input.get("input", null)
        )