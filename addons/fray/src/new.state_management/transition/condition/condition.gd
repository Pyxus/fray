extends Reference
## Abstract base condition class

## If true condition will be satisfied when condition is false
var invert: bool

## Returns whether the condition is true or false
func is_satisfied() -> bool:
    var s := _is_satisfied_impl()
    return s or not s and invert

## Returns true if this condition is equal to the given condition
func equals(condition: Reference) -> bool:
    return (
        condition is get_script() 
        and invert == condition.invert
        and _equals_impl(condition)
        )

## Abstract method used to define `equals` method
func _equals_impl(condition: Reference) -> bool:
    return false

## Abstract method used to define `is_satisfied` method
func _is_satisfied_impl() -> bool:
    push_error("Method not implemented.")
    return false