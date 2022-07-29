extends Control

signal save_request()

const FrayConfig = preload("res://addons/fray/fray_config.gd")

var _input_data: FrayInputNS.FrayInputData
var _input_name: String

onready var _property_container: Container = $"ScrollContainer/PropertyContainer"


func initialize(input_name: String, input_data: FrayInputNS.FrayInputData) -> void:
	_input_data = input_data
	_input_name = input_name
	_setup()


func get_input_data() -> FrayInputNS.FrayInputData:
	return _input_data


func get_input_name() -> String:
	return _input_name
	

func _setup() -> void:
	push_warning("Not implemented")


func _get_cyclic_ref_warning(component_input: String) -> String:
	var fray_config := FrayConfig.new()
	var trace := ""

	if _input_name == component_input:
		return "Combination contains self as direct component"
	elif fray_config.has_input(component_input):
		var input_data := fray_config.get_input(component_input)

		if input_data is FrayInputNS.CombinationInput:
			for component in input_data.components:
				if _input_name == component:
					trace += "%s -> %s" % [component_input, component]
					break
				else:
					var warning := _get_cyclic_ref_warning(component)
					if not warning.empty():
						trace += "%s -> %s -> %s" % [component_input, component, warning]
						break
		elif input_data is FrayInputNS.ConditionalInput:
			for con_input in input_data.input_by_condition.values() + [input_data.default_input]:
				if _input_name == con_input:
					trace += "%s -> %s" % [component_input, con_input]
					break
				else:
					var warning := _get_cyclic_ref_warning(con_input)
					if not warning.empty():
						trace += "%s -> %s -> %s" % [component_input, con_input, warning]
						break

	return trace