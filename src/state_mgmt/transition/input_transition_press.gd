class_name FrayInputTransitionPress
extends FrayInputTransition
## Input transition representing an atomic press input such as a key or button.
##
## Accepts input dictionary that contains these entires:
## [br] [br]
## - [code]input[/code] is the name of the input, as a [StringName];
## [br] [br]
## - [code]is_pressed[/code] is the state of the input, as a [bool];
## [br] [br]
## - [code]time_held[/code] is the time in seconds that the input was held for, as a [float].

## Input name.
@export var input: StringName = ""

## If [code]true[/code] the input is only accepted on release.
@export var is_triggered_on_release: bool = false

## Minimum time the input must be held in seconds. If negative then this check is ignored.
@export var min_time_held: float = -1.0

## Maximum time the input is allowed to be held in seconds. If negative then this check is ignored.
@export var max_time_held: float = -1.0


func _accepts_impl(sm_input: Dictionary) -> bool:
	return (
		super(sm_input)
		and sm_input.get("input", null) == input
		and sm_input.get("is_pressed", false) != is_triggered_on_release
		and (_can_ignore_min_time_held() or sm_input.get("time_held", 0.0) >= min_time_held)
		and (_can_ignore_max_time_held() or sm_input.get("time_held", 0.0) <= max_time_held)
	)


func _can_ignore_min_time_held() -> bool:
	return min_time_held < 0


func _can_ignore_max_time_held() -> bool:
	return max_time_held < 0
