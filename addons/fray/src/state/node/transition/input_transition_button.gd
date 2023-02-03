class_name FrayInputTransitionButton
extends FrayInputTransition

## Input name
var input: String

## If true the input is only accepted on release
var is_triggered_on_release: bool

func _accepts_impl(sm_input: Dictionary) -> bool:
	return (
		super(sm_input)
		and input == sm_input.get("input", null)
		and is_triggered_on_release != sm_input.get("input_is_pressed", false)
		)
