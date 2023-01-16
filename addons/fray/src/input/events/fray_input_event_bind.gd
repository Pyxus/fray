extends "fray_input_event.gd"
## Fray input event type for bind inputs

## An array of composite inputs that this bind was a part of when the event was emitted
## Type: Pesudo-HashSet
var composites_used_in: Dictionary

## Returns true if this input press was used as a part of a composite input press 
## when the event was emitted.
func is_used_in_composite() -> bool:
	return not composites_used_in.is_empty()
