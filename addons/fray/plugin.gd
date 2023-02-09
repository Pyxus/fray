@tool
extends EditorPlugin

var _added_types: Array
var _added_singletons: Array
var _editor_interface := get_editor_interface()
var _editor_settings := _editor_interface.get_editor_settings()

func _ready() -> void:
	pass

	
func _enter_tree() -> void:
	add_autoload_singleton("FrayInputMap", "res://addons/fray/src/input/autoloads/fray_input_map.gd")
	add_autoload_singleton("FrayInput", "res://addons/fray/src/input/autoloads/fray_input.gd")


func _exit_tree():
	for singleton in _added_singletons:
		remove_autoload_singleton(singleton)

	for type in _added_types:
		remove_custom_type(type)


func add_autoload_singleton(name: String, path: String) -> void:
	super(name, path)
	_added_singletons.append(name)


func add_custom_type(type: String, base: String, script: Script, icon: Texture2D) -> void:
	super(type, base, script, icon)
	_added_types.append(type)
