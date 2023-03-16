extends FrayStateMachine
## Basic implementation of state machine
##
## Contains a root propety, which can be updated to set  the root state node. Once the root state node is set, the state machine
## can begin processing state transitions.

var root: FrayStateNodeStateMachine

func _get_root_impl() -> FrayStateNodeStateMachine:
	return root