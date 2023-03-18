class_name FrayState
extends RefCounted
## Base state node class

# Type: WeakRef<StateNode>
var _parent_ref: WeakRef

# Type: Dictionary<StringName, bool>
# Hint: <condition name, condition status>
var _conditions: Dictionary

# Type: Dictionary<StringName, int>
# Hint: <condition name, usage count>
var _condition_usage_count: Dictionary

## Returns [code]true[/code] if state has the given [kbd]condition[/kbd].
func has_condition(condition: StringName) -> bool:
	return _conditions.has(condition)

## Returns the value of a [kbd]condition[/kbd] if it exists.
func is_condition_true(condition: StringName) -> bool:
	if not has_condition(condition):
		push_warning("Failed to check condition. Condition with name '%s' does not exist" % condition)
		return false

	return _conditions[condition]

## Sets the [kbd]value[/kbd] of a [kbd]condition[/kbd] if it exists.
func set_condition(condition: StringName, value: bool) -> void:
	if not has_condition(condition):
		push_warning("Condition '%s' does not exist")
		return
	
	_conditions[condition] = value

## Returns [code]true[/code] if this node is child of another node.
func has_parent() -> bool:
	return _parent_ref != null

## Returns the parent of this node if it exists.
func get_parent() -> FrayStateNode:
	return _parent_ref.get_ref() if has_parent() else null

## Returns [code]true[/code] if the node is considered to be done processing.
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

## [code]Virtual method[/code] used to implement [method is_done_processing].
func _is_done_processing_impl() -> bool:
	return true

## [code]Virtual method[/code] invoked when the node is first entered.
## [br]
## [kbd]args[/kbd] is user-defined data which is passed to the advanced node on enter. 
func _enter_impl(args: Dictionary) -> void:
	pass

## [code]Virtual method[/code] invoked when the node is being processed.
func _process_impl(_delta: float) -> void:
	pass


## [code]Virtual method[/code] invoked when the node is being physics processed.
func _physics_process_impl(_delta: float) -> void:
	pass

## [code]Virtual method[/code] invoked when the node is existed.
func _exit_impl() -> void:
	pass
