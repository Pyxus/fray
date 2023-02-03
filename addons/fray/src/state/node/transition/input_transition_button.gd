class_name FrayInputTransitionButton
extends FrayInputTransition

## Input name.
var input: StringName

## If true the input is only accepted on release.
var is_triggered_on_release: bool

## Minimum time the input must be held in seconds.
var min_time_held: float

func _accepts_impl(sm_input: Dictionary) -> bool:
	return (
		super(sm_input)
		and sm_input.get("input", null) == input
		and sm_input.get("input_is_pressed", false) != is_triggered_on_release
		and sm_input.get("time_held") >= min_time_held
		)
