@tool
class_name FraySimpleInput
extends FrayCompositeInput
## A composite input used as a wrapper around input binds
##
## Simple inputs do nothing with thier components and will ignore them.
## They are considered pressed when their bind is pressed.
## Simple inputs are intended to be the 'leaf' that ends any input composition.

## Name of the bind associated with this input
var bind: StringName


func _is_pressed_impl(device: int) -> bool:
	return get_bind_state(bind, device).is_pressed


## Returns a builder instance.
static func builder() -> Builder:
	return Builder.new()


## Returns a simple input using the given [kbd]bind[/kbd].
## [br]
## Shorthand for [code]builder().bind(bind).build()[/code]
static func from_bind(bind: StringName) -> FraySimpleInput:
	return builder().bind(bind).build()


func _decompose_impl(device: int) -> Array[StringName]:
	return [bind]


class Builder:
	extends FrayCompositeInput.Builder
	## [FraySimpleInput] builder.

	func _init() -> void:
		_composite_input = FraySimpleInput.new()
	
	## Builds the composite input
	## [br]
	## Returns a reference to the newly built simple input.
	func build() -> FraySimpleInput:
		return _composite_input

	## Adds a bind to this simple input.
	## [br]
	## Returns a reference to this ComponentBuilder.
	func bind(bind_name: StringName) -> Builder:
		_composite_input.bind = bind_name
		return self
