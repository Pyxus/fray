class_name FrayGroupInput
extends FrayCompositeInput
## A composite input used to create group inputs
##
## A group will be considered press when the
## minimum number of components in the group is pressed.

## The minimum number of components that must be pressed for the input to
## be considered as pressed.
@export var min_pressed: int = 1:
	set(value):
		min_pressed = max(1, value)

# Note: I really don't like the composite inputs maintaing state. They're really supposed to
#		just peek at the fray input state and determine if they're considered pressed.
#		But this is the only way I could think to handle their decomposition.
# Type: Dictionary<int, PackedStringArray>
var _last_inputs_by_device: Dictionary


## Returns a builder instance.
static func builder() -> Builder:
	return Builder.new()


func _is_pressed_impl(device: int) -> bool:
	var press_count := 0
	var last_inputs: Array[StringName] = []

	for component in _components:
		if component.is_pressed(device):
			last_inputs.append_array(component.decompose(device))
			press_count += 1

			if press_count >= min(min_pressed, _components.size()):
				_last_inputs_by_device[device] = last_inputs
				return true

	return false


func _decompose_impl(device: int) -> Array[StringName]:
	return _last_inputs_by_device[device] if _last_inputs_by_device.has(device) else []


class Builder:
	extends RefCounted
	## [FrayGroupInput] builder.

	var _composite_input = FrayGroupInput.new()

	## Builds the composite input.
	## [br]
	## Returns a reference to the newly built CompositeInput.
	func build() -> FrayGroupInput:
		return _composite_input

	## Sets the minimum number of components that must be pressed.
	## [br]
	## Returns a reference to this ComponentBuilder.
	func min_pressed(value: int) -> Builder:
		_composite_input.min_pressed = value
		return self

	## Adds a composite input as a component of this group.
	## [br]
	## Returns a reference to this ComponentBuilder.
	func add_component(composite_input: FrayCompositeInput) -> Builder:
		_composite_input.add_component(composite_input)
		return self

	## Adds a simple input as a component of this group
	## [br]
	## Returns a reference to this ComponentBuilder.
	func add_component_simple(bind: StringName) -> Builder:
		_composite_input.add_component(FraySimpleInput.from_bind(bind))
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
