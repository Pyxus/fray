class_name FrayInputTransitionSequence
extends FrayInputTransition

## Name of the sequence
var sequence_name: String

func _accepts_impl(sm_input: Dictionary) -> bool:
	return (
		super(sm_input)
		and sequence_name == sm_input.get("input", null)
		)
