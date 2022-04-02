extends Resource

var input_id: int
var min_time_held: float
var max_delay: float
var is_pressed_input: bool = true

func equals(input_requirement: Resource) -> bool:
    return input_requirement == self \
    or input_requirement.input_id == input_id \
    and input_requirement.min_time_held == min_time_held \
    and input_requirement.max_delay == max_delay \
    and input_requirement.is_pressed_input == is_pressed_input