class_name FrayInputTransitionSequence
extends FrayInputTransition
## Input transition representing a sequence input.
##
## Accepts input dictionary that contains these entires:
## [br] [br]
## - [code]sequence[/code] is the name of the input, as a [StringName];

## Name of the sequence.
var sequence: StringName = ""

func _accepts_impl(sm_input: Dictionary) -> bool:
	return (
		super(sm_input)
		and sm_input.get("sequence", null) == sequence
		)
