class_name FrayInputTransitionButton
extends FrayInputTransition
## Input transition representing an atomic input such as a key or button.

## Input name.
var input: StringName = ""

## If [code]true[/code] the input is only accepted on release.
var is_triggered_on_release: bool = false

## Minimum time the input must be held in milliseconds. If negative then this check is ignored.
var min_time_held: int = -1

## Maximum time the input is allowed to be held in milliseconds. If negative then this check is ignored.
var max_time_held: int = -1


func _accepts_impl(sm_input: Dictionary) -> bool:
	return (
		super(sm_input)
		and sm_input.get("input", null) == input
		and sm_input.get("input_is_pressed", false) != is_triggered_on_release
		and (_can_ignore_min_time_held() or sm_input.get("time_held", 0) >= min_time_held)
		and (_can_ignore_max_time_held() or sm_input.get("time_held", 0) <= max_time_held)
	)


func _can_ignore_min_time_held() -> bool:
	return sign(min_time_held) == -1


func _can_ignore_max_time_held() -> bool:
	return sign(max_time_held) == -1
