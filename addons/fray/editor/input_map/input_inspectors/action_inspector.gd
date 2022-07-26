tool
extends "input_inspector.gd"


onready var _action_name_edit: LineEdit = $"ScrollContainer/PropertyContainer/ActionProperty/ActionNameEdit"

func _setup() -> void:
	_action_name_edit.text = _input_data.action


func _on_ActionNameEdit_text_changed(new_text: String):
	_input_data.action = new_text
	emit_signal("save_request")
