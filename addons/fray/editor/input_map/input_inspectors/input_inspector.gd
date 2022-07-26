extends Control

signal save_request()

var _input_data: FrayInputNS.FrayInputData

onready var _property_container: Container = $"ScrollContainer/PropertyContainer"


func initialize(input_data: FrayInputNS.FrayInputData) -> void:
	_input_data = input_data
	_setup()


func get_input_data() -> FrayInputNS.FrayInputData:
	return _input_data


func _setup() -> void:
	push_warning("Not implemented")
