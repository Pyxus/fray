class_name FrayInputTransition
extends FrayStateMachineTransition
## Abstract input based transition class.
##
## Accepts input dictionary that contains these entires:
## [br] [br]
## - [code]time_since_last_input[/code] is the time in seconds since the last input was provided, as a [float].

## Minimum time that must have elapsed since the last input, in seconds. If negative then this check is ignored.
var min_input_delay: float = -1.0


func _accepts_impl(input: Dictionary) -> bool:
	return _can_ignore_min_input_delay() or input.get("time_since_last_input", 0) >= min_input_delay


func _can_ignore_min_input_delay() -> bool:
	return sign(min_input_delay) == -1
