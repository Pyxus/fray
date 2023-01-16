extends "input_transition.gd"

## Input name
var input: String

## If true the condition only counts the input if it is released
var is_triggered_on_release: bool

func _accepts_impl(sm_input: Dictionary) -> bool:
	return (
		super(sm_input)
		and input == sm_input.get("input", null)
		and is_triggered_on_release != sm_input.get("input_is_pressed", false)
		)
