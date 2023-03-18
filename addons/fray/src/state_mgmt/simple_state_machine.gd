class_name FraySimpleStateMachine
extends FrayStateMachine
## Basic implementation of [FrayStateMachine]
##
## Contains a root propety, which can be updated to set  the root state. Once the root state is set, the state machine
## can begin processing state transitions.

## The root of this state machine.
var root: FrayRootState

func _get_root_impl() -> FrayRootState:
	return root
