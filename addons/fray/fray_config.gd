tool
extends Reference

const SAVE_PATH = "res://addons/fray/fray.cfg"


var _config := ConfigFile.new()

func _init() -> void:
	var error := _config.load(SAVE_PATH)
	
	if error == ERR_FILE_NOT_FOUND:
		_config.save(SAVE_PATH)
	elif error != OK:
		push_error("Failed to load fray.cfg. Error '%d'" % error)


func save_input(input_name: String, input: FrayInputNS.FrayInputData) -> void:
	_config.set_value("input", input_name, input)
	save()
	

func delete_input(input_name: String) -> void:
	if _config.has_section_key("input", input_name):
		_config.erase_section_key("input", input_name)
		save()


func get_input(input_name: String) -> FrayInputNS.FrayInputData:
	return _config.get_value("input", input_name) as FrayInputNS.FrayInputData 
	

func get_input_names() -> PoolStringArray:

	if _config.has_section("input"):
		return _config.get_section_keys("input")
	return PoolStringArray()


func has_input(input: String) -> bool:
	return _config.has_section_key("input", input)


func save() -> void:
	var error = _config.save(SAVE_PATH)
	if error != OK:
		push_error("Failed to save input. Error '%d'" % error)