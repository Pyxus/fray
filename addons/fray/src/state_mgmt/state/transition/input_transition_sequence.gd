class_name FrayInputTransitionSequence
extends FrayInputTransition

## Name of the sequence.
var sequence: StringName = ""

func _accepts_impl(sm_input: Dictionary) -> bool:
	return (
		super(sm_input)
		and sm_input.get("sequence", null) == sequence
		)
