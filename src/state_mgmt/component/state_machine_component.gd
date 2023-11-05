@tool
class_name FrayStateMachineComponent
extends Node


func _get_configuration_warnings() -> PackedStringArray:
	if get_state_machine() == null:
		return ["This node is expected to be the the child of a FrayStateMachine."]
	return []

## Returns the state machine this component belongs to if it exists.
func get_state_machine() -> FrayStateMachine:
	return get_parent() as FrayStateMachine
