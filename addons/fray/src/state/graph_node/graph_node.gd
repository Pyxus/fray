extends Reference
## Base state class

## Type: WeakRef<State>
var _parent_ref: WeakRef

## Returns true if this state is child of another state.
func has_parent() -> bool:
	return _parent_ref != null

## Returns the parent of this state if it exists.
func get_parent() -> Reference:
	return _parent_ref.get_ref() if has_parent() else null

## Returns true if the state is considered to be done processing
func is_done_processing() -> bool:
	return _is_done_processing_impl()

## Virtual method used to implement `is_done_processing()`
func _is_done_processing_impl() -> bool:
	return true

## Virtual method invoked when the state is first entered
##
## `args` is user-defined data which is passed to the advanced state on enter. 
func _enter_impl(args: Dictionary) -> void:
	pass

## Virtual method invoked when the state is being processed
func _process_impl(_delta: float) -> void:
	pass

## Virtual method invoked when the state is being physics processed
func _physics_process_impl(_delta: float) -> void:
	pass

## Virtual method invoked when the state is existed
func _exit_impl() -> void:
	pass