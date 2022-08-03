extends Reference

const ComplexInput = preload("input_data/complex_input.gd")

static func new_combination() -> CombinationBuilder:
	return CombinationBuilder.new()


static func new_conditional():
	return ConditionalBuilder.new()


static func new_simple(binds: PoolStringArray = []):
	var builder := SimpleBuilder.new()
	builder.set_binds(binds) 
	return builder

class ComponentBuilder:
	extends Reference

	const ComplexInput = preload("input_data/complex_input.gd")

	var _complex_input: ComplexInput
	var _builders: Array ## ComponentBuilder[]

	func build() -> ComplexInput:
		for builder in _builders:
			_complex_input.add_component(builder.build())
		return _complex_input


class CombinationBuilder:
	extends ComponentBuilder

	const CombinationInput = preload("input_data/combination_input.gd")

	func _init() -> void:
		_complex_input = CombinationInput.new()


	func add_component(component_builder: ComponentBuilder) -> CombinationBuilder:
		_builders.append(component_builder)
		return self


	func mode(combination_mode: int) -> CombinationBuilder:
		_complex_input.mode = combination_mode
		return self
	

	func virtual(is_virtual: bool = true) -> CombinationBuilder:
		_complex_input.is_virtual = is_virtual
		return self
	

class ConditionalBuilder:
	extends ComponentBuilder

	const ConditionalInput = preload("input_data/conditional_input.gd")

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
	
	const SimpleInput = preload("input_data/simple_input.gd")

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

"""
builder.new_combination()
	.add_component(builder.new_simple()
		.bind("down")
		)
	.add_component(builder.new_simple()
		.bind("right")
		)
	.virtual()
	.mode()
	.build()

builder.new_conditional()
	.add_component(builder.new_combination()
		.add_component(builder.new_simple()
			.bind()
		)
		.add_component(builder.new_simple())
	)
"""
