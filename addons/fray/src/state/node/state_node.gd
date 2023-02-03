class_name FrayStateNode
extends RefCounted
## Base state node class

## Type: WeakRef<StateNodeBase>
var _parent_ref: WeakRef

# Type: Dictionary<StringName, bool>
# Hint: <condition name, condition status>
var _conditions: Dictionary

# Type: Dictionary<StringName, int>
# Hint: <condition name, usage count>
var _condition_usage_count: Dictionary

## Returns true if state has condition with given name.
func has_condition(name: StringName) -> bool:
	return _conditions.has(name)

## Returns the status of a condition in this node if it exists.
func check_condition(name: StringName) -> bool:
	if not has_condition(name):
		push_warning("Failed to check condition. Condition with name '%s' does not exist" % name)
		return false

	return _conditions[name]

## Sets the value of a condition if it exists.
func set_condition(name: StringName, value: bool) -> void:
	if not has_condition(name):
		push_warning("Condition '%s' does not exist")
		return
	
	_conditions[name] = value

## Returns true if this node is child of another node.
func has_parent() -> bool:
	return _parent_ref != null

## Returns the parent of this node if it exists.
func get_parent() -> RefCounted:
	return _parent_ref.get_ref() if has_parent() else null

## Returns true if the node is considered to be done processing
func is_done_processing() -> bool:
	return _is_done_processing_impl()


func _add_conditions(conditions: Array[FrayCondition]) -> void:
	for condition in conditions:
		if not has_condition(condition.name):
			_condition_usage_count[condition.name] = 1
			_conditions[condition.name] = false
		else:
			_condition_usage_count[condition.name] += 1


func _remove_conditions(conditions: Array[FrayCondition]) -> void:
	for condition in conditions:
		_condition_usage_count[condition.name] -= 1

		if _condition_usage_count[condition.name] < 1:
			_conditions.erase(condition.name)
			_condition_usage_count.erase(condition.name)

## [code]Virtual method[/code] used to implement `is_done_processing()`
func _is_done_processing_impl() -> bool:
	return true

## [code]Virtual method[/code] invoked when the node is first entered
##
## `args` is user-defined data which is passed to the advanced node on enter. 
func _enter_impl(args: Dictionary) -> void:
	pass

## [code]Virtual method[/code] invoked when the node is being processed
func _process_impl(_delta: float) -> void:
	pass


## [code]Virtual method[/code] invoked when the node is being physics processed
func _physics_process_impl(_delta: float) -> void:
	pass

## [code]Virtual method[/code] invoked when the node is existed
func _exit_impl() -> void:
	pass
