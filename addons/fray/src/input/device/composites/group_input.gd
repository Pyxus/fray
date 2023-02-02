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

# Type: Dictionary<int, PackedStringArray>
var _last_inputs_by_device: Dictionary

## Returns a builder instance
static func builder() -> Builder:
	return Builder.new()


func _is_pressed_impl(device: int, input_interface: FrayInputInterface) -> bool:
	var press_count := 0
	var last_inputs := PackedStringArray()
	
	for component in _components:
		if component.is_pressed(device, input_interface):
			last_inputs += component.decompose(device, input_interface)
			press_count += 1

			if press_count >= min(min_pressed, _components.size()):
				_last_inputs_by_device[device] = last_inputs
				return true

	return false


func _decompose_impl(device: int, input_interface: FrayInputInterface) -> PackedStringArray:
	return _last_inputs_by_device[device] if _last_inputs_by_device.has(device) else PackedStringArray()


class Builder:
	extends CompositeBuilder
	
	func _init() -> void:
		_composite_input = FrayGroupInput.new()

	## Sets the minimum number of components that must be pressed.
	##
	## Returns a reference to this ComponentBuilder
	func min_pressed(value: int) -> Builder:
		_composite_input.min_pressed = value
		return self

	## Adds a composite input as a component of this combination
	##
	## Returns a reference to this ComponentBuilder
	func add_component(composite_input: FrayCompositeInput) -> Builder:
		_composite_input.add_component(composite_input)
		return self

	## Sets whether the input will be virtual or not
	##
	## Returns a reference to this ComponentBuilder
	func is_virtual(value: bool = true) -> Builder:
		_composite_input.is_virtual = value
		return self

	## Sets the composite input's process priority
	##
	## Returns a reference to this ComponentBuilder
	func priority(value: int) -> Builder:
		_composite_input.priority = value
		return self
