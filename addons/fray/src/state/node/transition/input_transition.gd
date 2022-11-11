extends "state_machine_transition.gd"
## Abstract input based transition class

## Minimum time that must have elapsed since the last input
var min_input_delay: float

func _accepts_impl(input: Dictionary) -> bool:
    return input.get("time_since_last_input", 0.0) >= min_input_delay