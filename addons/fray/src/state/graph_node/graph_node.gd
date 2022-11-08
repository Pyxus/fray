extends Reference
## Base state class

## Type: WeakRef<State>
var _parent_ref: WeakRef

## Type: Dictionary<String, bool>
## Hint: <condition name, condition status>
var _conditions: Dictionary

## Type: Dictionary<String, int>
## Hint: <condition name, usage count>
var _condition_usage_count: Dictionary

## Returns true if graph has condition with given name.
func has_condition(name: String) -> bool:
	return _conditions.has(name)

## Returns the status of a condition in this state machine if it exists.
func check_condition(name: String) -> bool:
	if not has_condition(name):
		push_warning("Failed to check condition. Condition with name '%s' does not exist" % name)
		return false

	return _conditions[name]

## Sets the value of a condition if it exists.
func set_condition(name: String, value: bool) -> void:
	if not has_condition(name):
		push_warning("Condition '%s' does not exist")
		return
	
	_conditions[name] = value

## Returns true if this state is child of another state.
func has_parent() -> bool:
	return _parent_ref != null

## Returns the parent of this state if it exists.
func get_parent() -> Reference:
	return _parent_ref.get_ref() if has_parent() else null

## Returns true if the state is considered to be done processing
func is_done_processing() -> bool:
	return _is_done_processing_impl()

## `conditions: Condition[]`
func _add_conditions(conditions: Array) -> void:
	for condition in conditions:
		if not has_condition(condition.name):
			_condition_usage_count[condition.name] = 1
			_conditions[condition.name] = false
		else:
			_condition_usage_count[condition.name] += 1

## `conditions: Condition[]`
func _remove_conditions(conditions: Array) -> void:
	for condition in conditions:
		_condition_usage_count[condition.name] -= 1

		if _condition_usage_count[condition.name] < 1:
			_conditions.erase(condition.name)
			_condition_usage_count.erase(condition.name)

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
