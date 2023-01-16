@tool
extends "composite_input.gd"

## A composite input used to create conditional inputs
##
## @desc:
##      Returns whether a specific component is pressed based on a string condition.
##      Useful for creating directional inputs which change based on what side a
##      combatant stands on as is seen in many 2D fighting games.
##
##      If no condition is true then the input will default to checking the first component.


## Type: Dictionary<int, String>
## Hint: <component index, string condition>
var _conditions_by_component: Dictionary


func set_condition(component_index: int, condition: String) -> void:
	if component_index == 0:
		push_warning("The first component is treated as the default input. Condition will be ignored")
		return

	if component_index >= 1 and component_index < _components.size():
		_conditions_by_component[component_index] = condition
	else:
		push_warning("Failed to set condition on input. Given index out of range")
		

func _is_pressed_impl(device: int, input_interface: InputInterface) -> bool:
	if _components.is_empty():
		push_warning("Conditional input has no components")
		return false

	var comp: Resource = _components[0]

	for component_index in _conditions_by_component:
		var component: Resource = _components[component_index]
		var condition: String = _conditions_by_component[component_index]

		if input_interface.is_condition_true(condition, device):
			comp = component
			break

	return comp.is_pressed(device, input_interface)


func _decompose_impl(device: int, input_interface: InputInterface) -> PackedStringArray:
	# Returns the first component with a true condition. Defaults to component at index 0

	if _components.is_empty():
		return PackedStringArray()

	var component: Resource = _components[0]
	for component_index in _conditions_by_component:
		var comp: Resource = _components[component_index]
		var condition: String = _conditions_by_component[component_index]

		if input_interface.is_condition_true(condition, device):
			component = comp
			break
	return component.decompose(device, input_interface)
