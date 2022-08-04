extends Reference

const ComplexInput = preload("complex_input.gd")

## Returns a new combination input builder
static func new_combination() -> CombinationBuilder:
	return CombinationBuilder.new()

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

	const ComplexInput = preload("complex_input.gd")

	var _complex_input: ComplexInput
	var _builders: Array ## ComponentBuilder[]

	func build() -> ComplexInput:
		for builder in _builders:
			_complex_input.add_component(builder.build())
		return _complex_input


	func virtual(is_virtual: bool = true) -> ComponentBuilder:
		_complex_input.is_virtual = is_virtual
		return self


class CombinationBuilder:
	extends ComponentBuilder

	const CombinationInput = preload("combination_input.gd")

	func _init() -> void:
		_complex_input = CombinationInput.new()


	func add_component(component_builder: ComponentBuilder) -> CombinationBuilder:
		_builders.append(component_builder)
		return self


	func mode(combination_mode: int) -> CombinationBuilder:
		_complex_input.mode = combination_mode
		return self
	

class ConditionalBuilder:
	extends ComponentBuilder

	const ConditionalInput = preload("conditional_input.gd")

	var _conditions: Array

	func _init() -> void:
		_complex_input = ConditionalInput.new()


	func add_component(condition: String, component_builder: ComponentBuilder):
		_conditions.append(condition)
		_builders.append(component_builder)
		return self 
	

	func build() -> ComplexInput:
		for i in len(_builders):
			_complex_input.add_component(_builders[i].build())
			
			if i != 0:
				_complex_input.set_condition(i, _conditions[i])
		return _complex_input


class SimpleBuilder:
	extends ComponentBuilder
	
	const SimpleInput = preload("simple_input.gd")

	func _init() -> void:
		_complex_input = SimpleInput.new()


	func bind(bind_name: String) -> SimpleBuilder:
		_complex_input.binds.append(bind_name)
		return self
	

	func set_binds(bind_names: PoolStringArray) -> SimpleBuilder:
		_complex_input.binds = bind_names
		return self


	func build() -> ComplexInput:
		return _complex_input
