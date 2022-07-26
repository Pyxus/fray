extends Control

signal save_request()

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
