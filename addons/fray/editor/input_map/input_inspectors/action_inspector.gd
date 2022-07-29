tool
extends "input_inspector.gd"

var _godot_config := ConfigFile.new()

onready var _action_name_edit: LineEdit = $"ScrollContainer/PropertyContainer/ActionProperty/ActionNameEdit"
onready var _warning: TextureRect = $"ScrollContainer/PropertyContainer/ActionProperty/MarginContainer/Warning"


func _ready() -> void:
	var error := _godot_config.load("project.godot")
	if error != OK:
		push_error("Failed to load project.godot")


func _setup() -> void:
	_action_name_edit.text = _input_data.action
	_handle_warnings()


func _handle_warnings() -> void:
	if _godot_config.has_section("input"):
		var action_name = _action_name_edit.text
		if not _godot_config.has_section_key("input", action_name):
			_warning.show()
			_warning.hint_tooltip = "Warning:\nAn action with the name '%s' does not exist" % action_name
		else:
			_warning.hide()
		

func _on_ActionNameEdit_text_changed(new_text: String):
	_input_data.action = new_text
	emit_signal("save_request")
	_handle_warnings()
