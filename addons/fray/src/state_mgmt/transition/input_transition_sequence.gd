class_name FrayInputTransitionSequence
extends FrayInputTransition
## Input transition representing a sequence input.

## Name of the sequence.
var sequence: StringName = ""

func _accepts_impl(sm_input: Dictionary) -> bool:
	return (
		super(sm_input)
		and sm_input.get("sequence", null) == sequence
		)
