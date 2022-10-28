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


func _enter_impl(args: Dictionary) -> void:
	pass


func _process_impl(_delta: float) -> void:
	pass


func _physics_process_impl(_delta: float) -> void:
	pass


func _exit_impl() -> void:
	pass