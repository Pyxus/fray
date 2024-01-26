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
	extends FrayCompositeInput.Builder
	## [FrayGroupInput] builder.

	func _init() -> void:
		_composite_input = FrayGroupInput.new()
	
	## Builds the composite input
	## [br]
	## Returns a reference to the newly built composite input.
	func build() -> FrayGroupInput:
		return _composite_input

	## Sets the minimum number of components that must be pressed.
	## [br]
	## Returns a reference to this builder.
	func min_pressed(value: int) -> Builder:
		_composite_input.min_pressed = value
		return self

	func add_component(composite_input: FrayCompositeInput) -> Builder:
		return super(composite_input)
	
	func add_component_simple(bind: StringName) -> Builder:
		return super(bind)

	func is_virtual(value: bool = true) -> Builder:
		return super(value)

	func priority(value: int) -> Builder:
		return super(value)