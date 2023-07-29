class_name FrayGeneralStateMachine
extends FrayStateMachine
## Basic implementation of [FrayStateMachine] intended for general purpose state management.
##
## Contains a root propety, which can be updated to set  the root state. Once the root state is set, the state machine
## can begin processing state transitions.

## The root of this state machine.
var root: FrayRootState:
	set(value):
		if root != null and root.transitioned.is_connected(_on_RootState_transitioned):
			root.transitioned.disconnect(_on_RootState_transitioned)
		
		root = value

		root.transitioned.connect(_on_RootState_transitioned)

func _get_root_impl() -> FrayRootState:
	return root


func _on_RootState_transitioned(from: StringName, to: StringName) -> void:
	state_changed.emit(from, to)