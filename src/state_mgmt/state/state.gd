class_name FrayState
extends Resource
## Base state class

# Type: WeakRef<CompoundState>
var _root_ref: WeakRef

# Type: WeakRef<CompoundState>
var _parent_ref: WeakRef

# Type: Dictionary<Signal, Array[Callable]>
var _callables_by_signal: Dictionary


## Returns [code]true[/code] if this state is child of another state.
func has_parent() -> bool:
	return _parent_ref != null


## Returns the parent of this state if it exists.
func get_parent() -> FrayCompoundState:
	return _parent_ref.get_ref() if has_parent() else null


## Returns the root of of this state's hierarchy.
func get_root() -> FrayCompoundState:
	return _root_ref.get_ref() if _root_ref != null else null


## Returns [code]true[/code] if the state is considered to be done processing.
func is_done_processing() -> bool:
	return _is_done_processing_impl()


## Returns the node located at the given [kbd]path[/kbd] relative to the state machine.
func get_node(path: NodePath) -> Node:
	return get_root().get_node(path)


## Returns the first node of a given [kbd]type[/kbd] attached to this state machine.
func get_node_of_type(type: Variant) -> Node:
	return get_root().get_node_of_type(type)


## Returns all nodes of a given [kbd]type[/kbd] attached to this state machine.
func get_nodes_of_type(type: Variant) -> Array[Node]:
	return get_root().get_nodes_of_type(type)


## Process child states then this state.
## This method is intended to only be used by the [FrayCompoundState] when exiting sub-states.
func exit() -> void:
	for sig in _callables_by_signal:
		for callable in _callables_by_signal[sig]:
			if sig.is_connected(callable):
				sig.disconnect(callable)

	_callables_by_signal.clear()
	_exit_impl()


## Connects a signal which disconnects when this state is no longer active.
func connect_while_active(sig: Signal, callable: Callable, flags: int = 0) -> Error:
	if not sig.is_connected(callable):
		if not _callables_by_signal.has(sig):
			_callables_by_signal[sig] = []

		_callables_by_signal[sig].append(callable)

	return sig.connect(callable, flags)


## [code]Virtual method[/code] used to implement [method is_done_processing].
func _is_done_processing_impl() -> bool:
	return true


## [code]Virtual method[/code] invoked when the state machine is initialized. Child states are readied before parent states.
## [br]
## [kbd]context[/kbd] is read-only dictionary which provides a way to pass data which is available to all states within a hierachy.
func _ready_impl(context: Dictionary) -> void:
	pass


## [code]Virtual method[/code] invoked when the state is entered.
## [br]
## [kbd]args[/kbd] is user-defined data which is passed to the advanced state on enter.
func _enter_impl(args: Dictionary) -> void:
	pass


## [code]Virtual method[/code] invoked when the state is existed.
func _exit_impl() -> void:
	pass


## [code]Virtual method[/code] invokved when the state is added to the state machine hierarchy.
func _enter_tree_impl() -> void:
	pass


## [code]Virtual method[/code] invoked when the state is being processed. [kbd]delta[/kbd] is in seconds.
func _process_impl(delta: float) -> void:
	pass


## [code]Virtual method[/code] invoked when the state is being physics processed. [kbd]delta[/kbd] is in seconds.
func _physics_process_impl(delta: float) -> void:
	pass


## [code]Virtual method[/code] invoked when there is a godot input event.
func _input_impl(event: InputEvent) -> void:
	pass


## [code]Virtual method[/code] invoked when there is a godot input event that has not been consumed by [method Node._input].
func _unhandled_input_impl(event: InputEvent) -> void:
	pass
