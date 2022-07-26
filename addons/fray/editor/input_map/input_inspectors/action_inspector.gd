tool
extends "input_inspector.gd"


onready var _action_name_edit: LineEdit = $"ScrollContainer/PropertyContainer/ActionProperty/ActionNameEdit"
onready var _warning: TextureRect = $"ScrollContainer/PropertyContainer/ActionProperty/MarginContainer/Warning"


func _setup() -> void:
	_action_name_edit.text = _input_data.action


func _process(delta: float) -> void:
	var action_name = _action_name_edit.text
	if not InputMap.has_action(action_name):
		_warning.show()
		_warning.hint_tooltip = "Warning:\nAn action with the name '%s' does not exist" % action_name
	else:
		_warning.hide()
		

func _on_ActionNameEdit_text_changed(new_text: String):
	_input_data.action = new_text
	emit_signal("save_request")
