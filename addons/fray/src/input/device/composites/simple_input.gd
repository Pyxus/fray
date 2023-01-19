@tool
class_name FraySimpleInput
extends "composite_input.gd"
## A composite input used as a wrapper around input binds
##
## @desc:
## 		Simple inputs do nothing with thier component and will ignore them.
##      They are similar to godot actions in that they hold an array of input binds and are
##      considered to be pressed when any bind in the array is pressed.
##      Simple inputs are intended to be the 'leaf' that ends any input composition.

var binds: PackedStringArray


func _is_pressed_impl(device: int, input_interface: FrayInputInterface) -> bool:
	for bind in binds:
		var bind_state: FrayInputState = input_interface.get_bind_state(bind, device)
		if bind_state.is_pressed:
			return true
	return false


static func builder() -> Builder:
	return Builder.new()


func set_virtual(value: bool) -> void:
	super(value)
	if is_virtual:
		push_warning("Conditionals by design always overlap with their components. A conditional will never trigger a virtual press.")

		
func _decompose_impl(device: int, input_interface: FrayInputInterface) -> PackedStringArray:
	# Returns the most recently pressed bind
	var most_recent_bind: FrayInputState
	for bind in binds:
		var bind_state: FrayInputState = input_interface.get_bind_state(bind, device)

		if most_recent_bind != null:
			if most_recent_bind.time_pressed < bind_state.time_pressed:
				most_recent_bind = bind_state
		else:
			most_recent_bind = bind_state
	
	return PackedStringArray([most_recent_bind.input])


class Builder:
	extends CompositeBuilder
	
	func _init() -> void:
		_composite_input = FraySimpleInput.new()

	## Adds a bind to this simple input
	##
	## Returns a reference to this ComponentBuilder
	func bind(bind_name: String) -> Builder:
		_composite_input.binds.append(bind_name)
		return self
	
	## Sets an array of binds to this simple input
	##
	## Returns a reference to this ComponentBuilder
	func set_binds(bind_names: PackedStringArray) -> Builder:
		_composite_input.binds = bind_names
		return self

	## Sets wthe composite input's process priority
	##
	## Returns a reference to this ComponentBuilder
	func is_virtual(value: bool = true) -> Builder:
		_composite_input.is_virtual = value
		return self

	## Sets whether the input will be virtual or not
	##
	## Returns a reference to this ComponentBuilder
	func priority(value: int) -> Builder:
		_composite_input.priority = value
		return self

	func build() -> FrayCompositeInput:
		return _composite_input
