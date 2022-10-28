extends "condition_input.gd"
## Condition that is satisfied by buffered input button
##
## @desc:
##      A 'button' in this context is simply a non-sequence input.
##      It does not only refer to buttons on a controller.

const BufferedInputButton = preload("../../buffered_input/buffered_input_button.gd")

## Input name
var input: String

## If true the condition only counts the input if it is released
var is_triggered_on_release: bool

func _equals_impl(condition: Reference) -> bool:
    return (
        ._equals_impl(condition)
        and input == condition.input
        and is_triggered_on_release == condition.is_triggered_on_release
    )
func _is_satisfied_impl() -> bool:
    var buffered_input := _get_buffered_input() as BufferedInputButton
    if buffered_input == null:
        return false

    return (
        buffered_input.input == input 
        and buffered_input.is_pressed != is_triggered_on_release
        and ._is_satisfied_impl()
        )