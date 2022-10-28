extends "condition.gd"
## Abstract base input condition class

const BufferedInput = preload("../../buffered_input/buffered_input.gd")

## Type: () -> BufferedInput
var func_get_buffered_input: FuncRef

## Type: () -> float
var func_get_time_since_last_input: FuncRef

## Minimum time that must have elapsed since the last input
var min_input_delay: float

func _init(func_get_buffered_input: FuncRef, func_get_time_since_last_input: FuncRef) -> void:
    self.func_get_buffered_input = func_get_buffered_input
    self.func_get_time_since_last_input = func_get_time_since_last_input


func _equals_impl(condition: Reference) -> bool:
    return condition.min_input_delay == min_input_delay


func _get_buffered_input() -> BufferedInput:
    if func_get_buffered_input.is_valid():
        return func_get_buffered_input.call_func()
    else:
        push_error("Failed to get buffered input. 'func_get_buffered_input' FuncRef is no longer valid.")
        return null


func _get_time_since_last_input() -> float:
    if func_get_buffered_input.is_valid():
        return func_get_time_since_last_input.call_func()
    else:
        push_error("Failed to get buffered input. 'func_get_buffered_input' FuncRef is no longer valid.")
        return -1.0


func _is_satisfied_impl() -> bool:
    return _get_time_since_last_input() >= min_input_delay