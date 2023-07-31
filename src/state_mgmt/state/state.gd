class_name FrayState
extends RefCounted
## Base state class

# Type: WeakRef<State>
var _parent_ref: WeakRef

## Returns [code]true[/code] if this state is child of another state.
func has_parent() -> bool:
	return _parent_ref != null

## Returns the parent of this state if it exists.
func get_parent() -> FrayState:
	return _parent_ref.get_ref() if has_parent() else null

## Returns [code]true[/code] if the state is considered to be done processing.
func is_done_processing() -> bool:
	return _is_done_processing_impl()

## [code]Virtual method[/code] used to implement [method is_done_processing].
func _is_done_processing_impl() -> bool:
	return true

## [code]Virtual method[/code] invoked when the state is first entered.
## [br]
## [kbd]args[/kbd] is user-defined data which is passed to the advanced state on enter. 
func _enter_impl(args: Dictionary) -> void:
	pass

## [code]Virtual method[/code] invoked when the state is being processed.
func _process_impl(_delta: float) -> void:
	pass


## [code]Virtual method[/code] invoked when the state is being physics processed.
func _physics_process_impl(_delta: float) -> void:
	pass

## [code]Virtual method[/code] invoked when the state is existed.
func _exit_impl() -> void:
	pass


