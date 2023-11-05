@tool
class_name FrayStateMachineComponent
extends Node
## Base state machine component.
##
## State machine components are nodes which can be referenced within states through the [method FrayState.get_component] method.
## Components provide a centralized means for states to interface and learn about external objects.

# Note there honestly isn't much reason for this class beyond limiting which child nodes are conidered components.
# It doesn't provide any new functionality and the included components can function just fine without it.
# I could remove components and just make it so state machine's can share their child nodes to their states.
# We'll see, i'm still thinking things through...

func _get_configuration_warnings() -> PackedStringArray:
	if get_state_machine() == null:
		return ["This node is expected to be the the child of a FrayStateMachine."]
	return []

## Returns the state machine this component belongs to if it exists.
func get_state_machine() -> FrayStateMachine:
	return get_parent() as FrayStateMachine
