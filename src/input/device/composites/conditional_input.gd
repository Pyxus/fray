@tool
class_name FrayConditionalInput
extends FrayCompositeInput

## A composite input used to create conditional inputs
##
## @desc:
##      Returns whether a specific component is pressed based on a string condition.
##      Useful for creating directional inputs which change based on what side a
##      combatant stands on as is seen in many 2D fighting games.
##
##      If no condition is true then the input will default to checking the first component.

# Type: Array[func(device: int) -> bool]; index=component_index
var _conditions: Array[Callable]


## Returns a builder instance.
static func builder() -> Builder:
	return Builder.new()


## Sets the condition associated with a given component.
## [br]
## [kbd]component_index[/kbd] is the index of the component based on the order added.
## [br]
## [kbd]condition[/kbd] is a function of type func(device: int) -> bool.
func set_condition(component_index: int, condition: Callable) -> void:
	if component_index == 0:
		push_warning(
			"The first component is treated as the default input. Condition will be ignored"
		)
	elif component_index >= 1 and component_index < _components.size():
		_conditions[component_index - 1] = condition
	else:
		push_warning("Failed to set condition on input. Given index out of range")


func add_component(component: FrayCompositeInput) -> void:
	super(component)

	if get_component_count() > 1:
		_conditions.append(Callable())


func _is_pressed_impl(device: int) -> bool:
	if _components.is_empty():
		push_warning("Conditional input has no components")
		return false

	return _get_active_component(device).is_pressed(device)


func _decompose_impl(device: int) -> Array[StringName]:
	# Returns the first component with a true condition. Defaults to component at index 0

	if _components.is_empty():
		return []

	return _get_active_component(device).decompose(device)


func _get_active_component(device: int) -> FrayCompositeInput:
	var comp: FrayCompositeInput = _components[0]

	for i in len(_conditions):
		var condition := _conditions[i]

		if condition.is_null():
			push_error(
				"Failed to check condition for component at index %d. Condition not set." % [i + 1]
			)
			return comp

		if _conditions[i].call(device):
			comp = _components[i + 1]
			break
	return comp


class Builder:
	extends RefCounted

	var _composite_input: FrayConditionalInput = FrayConditionalInput.new()

	## Builds the composite input
	## [br]
	## Returns a reference to the newly built CompositeInput
	func build() -> FrayCompositeInput:
		return _composite_input

	## Adds a composite input as a component of this conditional input
	## [br]
	## Returns a reference to this ComponentBuilder
	func add_component(composite_input: FrayCompositeInput) -> Builder:
		_composite_input.add_component(composite_input)
		return self

	## Sets the condition of the previously added component.
	## Will do nothing for the first component added as this component is trated as default.
	## [br]
	## Returns a reference to this ComponentBuilder
	func use_condition(condition: Callable) -> Builder:
		var component_count := _composite_input.get_component_count()

		if component_count == 0:
			push_warning("No components have been added. Condition will be ignored.")
		elif component_count == 1:
			push_warning("The first component is treated as default. Condition will be ignored.")
		else:
			_composite_input.set_condition(component_count - 1, condition)

		return self

	## Sets whether the input will be virtual or not.
	## If true, components that are still held when the composite is released
	## will be treated as if they were just pressed again.
	## [br]
	## Returns a reference to this ComponentBuilder
	func is_virtual(value: bool = true) -> Builder:
		_composite_input.is_virtual = value
		return self

	## Sets the composite input's process priority. Higher priority composites are processed first.
	## [br]
	## Returns a reference to this ComponentBuilder
	func priority(value: int) -> Builder:
		_composite_input.priority = value
		return self
