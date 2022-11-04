extends Reference
## Static helper class used to construct composite inputs

const CompositeInput = preload("composite_input.gd")
const CombinationInput = preload("combination_input.gd")

## Returns a new combination input builder
static func new_combination() -> CombinationBuilder:
	return CombinationBuilder.new()

## Returns a new combination input builder with mode set to sync
static func new_combination_sync() -> CombinationBuilder:
	var builder := CombinationBuilder.new()
	builder.mode(CombinationInput.Mode.SYNC)
	return builder

## Returns a new combination input builder with mode set to async
static func new_combination_async() -> CombinationBuilder:
	var builder := CombinationBuilder.new()
	builder.mode(CombinationInput.Mode.ASYNC)
	return builder

## Returns a new combination input builder with mode set to ordered
static func new_combination_ordered() -> CombinationBuilder:
	var builder := CombinationBuilder.new()
	builder.mode(CombinationInput.Mode.ORDERED)
	return builder
	
## Returns a new conditional input builder
static func new_conditional():
	return ConditionalBuilder.new()

## Returns a new simple input builder
static func new_simple(binds: PoolStringArray = []):
	var builder := SimpleBuilder.new()
	builder.set_binds(binds) 
	return builder


class ComponentBuilder:
	extends Reference

	const CompositeInput = preload("composite_input.gd")

	var _composite_input: CompositeInput
	var _builders: Array ## ComponentBuilder[]

	## Builds the composite input
	##
	## Returns a reference to the newly build CompositeInput
	func build() -> CompositeInput:
		for builder in _builders:
			_composite_input.add_component(builder.build())
		return _composite_input

	## Sets whether the input will be virtual or not
	##
	## Returns a reference to this ComponentBuilder
	func virtual(is_virtual: bool = true) -> Reference:
		_composite_input.is_virtual = is_virtual
		return self


class CombinationBuilder:
	extends ComponentBuilder

	const CombinationInput = preload("combination_input.gd")

	func _init() -> void:
		_composite_input = CombinationInput.new()
		pass

	## Adds a composite input as a component of this combination
	##
	## Returns a reference to this ComponentBuilder
	func add_component(component_builder: Reference) -> Reference:
		_builders.append(component_builder)
		return self

	## Sets the combination mode
	##
	## Returns a reference to this ComponentBuilder
	func mode(combination_mode: int) -> Reference:
		_composite_input.mode = combination_mode
		return self
	

class ConditionalBuilder:
	extends ComponentBuilder

	const ConditionalInput = preload("conditional_input.gd")

	var _conditions: Array

	func _init() -> void:
		_composite_input = ConditionalInput.new()

	## Adds a composite input as a component of this conditional input
	##
	## Returns a reference to this ComponentBuilder
	func add_component(condition: String, component_builder: Reference):
		_conditions.append(condition)
		_builders.append(component_builder)
		return self 
	

	func build() -> CompositeInput:
		for i in len(_builders):
			_composite_input.add_component(_builders[i].build())
			
			if i != 0:
				_composite_input.set_condition(i, _conditions[i])
		return _composite_input


class SimpleBuilder:
	extends ComponentBuilder
	
	const SimpleInput = preload("simple_input.gd")

	func _init() -> void:
		_composite_input = SimpleInput.new()

	## Adds a bind to this simple input
	##
	## Returns a reference to this ComponentBuilder
	func bind(bind_name: String) -> Reference:
		_composite_input.binds.append(bind_name)
		return self
	
	## Sets an array of binds to this simple input
	##
	## Returns a reference to this ComponentBuilder
	func set_binds(bind_names: PoolStringArray) -> Reference:
		_composite_input.binds = bind_names
		return self


	func build() -> CompositeInput:
		return _composite_input
