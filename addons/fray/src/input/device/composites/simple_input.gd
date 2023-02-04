@tool
class_name FraySimpleInput
extends FrayCompositeInput
## A composite input used as a wrapper around input binds
##
## @desc:
## 		Simple inputs do nothing with thier components and will ignore them.
##		They are considered pressed when their bind is pressed.
##      Simple inputs are intended to be the 'leaf' that ends any input composition.

## Name of the bind associated with this input
var bind: StringName

func _is_pressed_impl(device: int, input_interface: FrayInputInterface) -> bool:
	return input_interface.get_bind_state(bind, device).is_pressed

## Returns a builder instance
static func builder() -> Builder:
	return Builder.new()

## Returns a simple input using the given [kbd]bind[/kbd].
static func from_bind(bind: StringName) -> FraySimpleInput:
	return builder().bind(bind).build()


func _decompose_impl(device: int, input_interface: FrayInputInterface) -> PackedStringArray:
	return PackedStringArray([bind])


class Builder:
	extends CompositeBuilder
	
	func _init() -> void:
		_composite_input = FraySimpleInput.new()

	## Adds a bind to this simple input
	##
	## Returns a reference to this ComponentBuilder
	func bind(bind_name: StringName) -> Builder:
		_composite_input.bind = bind_name
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
