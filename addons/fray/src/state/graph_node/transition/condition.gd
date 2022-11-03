extends Reference
## Abstract base condition class

## If true condition will be satisfied when false
var invert: bool

## Name of this condition
var name: String


func _init(condition_name: String = "", is_invert: bool = false) -> void:
    name = condition_name
    invert = is_invert


## Returns true if this condition is equal to the given condition
func equals(condition: Reference) -> bool:
    return (
        condition is get_script() 
        and invert == condition.invert
        and name == condition.name
        )