class_name FrayState
extends Resource
## Base state class

# Type: WeakRef<CompoundState>
var _root_ref: WeakRef

# Type: WeakRef<CompoundState>
var _parent_ref: WeakRef


## Returns [code]true[/code] if this state is child of another state.
func has_parent() -> bool:
	return _parent_ref != null


## Returns the parent of this state if it exists.
func get_parent() -> FrayCompoundState:
	return _parent_ref.get_ref() if has_parent() else null


## Returns the root of of this state's hierarchy.
## If this state is has no root then null will be returned.
func get_root() -> FrayCompoundState:
	return _root_ref.get_ref() if _root_ref != null else null


## Returns [code]true[/code] if the state is considered to be done processing.
func is_done_processing() -> bool:
	return _is_done_processing_impl()


## [code]Virtual method[/code] used to implement [method is_done_processing].
func _is_done_processing_impl() -> bool:
	return true


## [code]Virtual method[/code] invoked when this state is added to the state machine tree.
func _ready_impl() -> void:
	pass


## [code]Virtual method[/code] invoked when the state is entered.
## [br]
## [kbd]args[/kbd] is user-defined data which is passed to the advanced state on enter.
func _enter_impl(args: Dictionary) -> void:
	pass


## [code]Virtual method[/code] invoked when the state is existed.
func _exit_impl() -> void:
	pass


## [code]Virtual method[/code] invoked when the state is being processed.
func _process_impl(_delta: float) -> void:
	pass


## [code]Virtual method[/code] invoked when the state is being physics processed.
func _physics_process_impl(_delta: float) -> void:
	pass


## [code]Virtual method[/code] invoked when there is a godot input event.
func _input_impl(event: InputEvent) -> void:
	pass


## [code]Virtual method[/code] invoked when there is a godot input event that has not been consumed by [method Node._input].
func _unhandled_input_impl(event: InputEvent) -> void:
	pass
