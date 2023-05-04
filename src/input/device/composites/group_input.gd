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


func _is_pressed_impl(device: int, input_interface: FrayInputInterface) -> bool:
	var press_count := 0
	var last_inputs: Array[StringName] = []
	
	for component in _components:
		if component.is_pressed(device, input_interface):
			last_inputs.append_array(component.decompose(device, input_interface))
			press_count += 1

			if press_count >= min(min_pressed, _components.size()):
				_last_inputs_by_device[device] = last_inputs
				return true

	return false


func _decompose_impl(device: int, input_interface: FrayInputInterface) -> Array[StringName]:
	return _last_inputs_by_device[device] if _last_inputs_by_device.has(device) else []


class Builder:
	extends RefCounted
	## [FrayGroupInput] builder.
	
	var _composite_input = FrayGroupInput.new()

	## Builds the composite input.
	##
	## Returns a reference to the newly built CompositeInput.
	func build() -> FrayGroupInput:
		return _composite_input

	## Sets the minimum number of components that must be pressed.
	##
	## Returns a reference to this ComponentBuilder.
	func min_pressed(value: int) -> Builder:
		_composite_input.min_pressed = value
		return self

	## Adds a composite input as a component of this combination.
	##
	## Returns a reference to this ComponentBuilder.
	func add_component(composite_input: FrayCompositeInput) -> Builder:
		_composite_input.add_component(composite_input)
		return self

	## Sets the input as virtual.
	##
	## Returns a reference to this ComponentBuilder.
	func is_virtual() -> Builder:
		_composite_input.is_virtual = true
		return self

	## Sets the composite input's process priority. Higher priority composites are processed first.
	##
	## Returns a reference to this ComponentBuilder.
	func priority(value: int) -> Builder:
		_composite_input.priority = value
		return self
