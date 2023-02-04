class_name FrayCondition
extends RefCounted
## Abstract base condition class

## If true condition will be satisfied when false
var invert: bool

## Name of this condition
var name: StringName

func _init(condition_name: StringName = "", is_invert: bool = false) -> void:
	name = condition_name
	invert = is_invert


## Returns true if this condition is equal to the given condition
func equals(condition: RefCounted) -> bool:
	return (
		condition is FrayCondition
		and invert == condition.invert
		and name == condition.name
		)
