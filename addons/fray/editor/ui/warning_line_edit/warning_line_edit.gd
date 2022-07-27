tool
extends HBoxContainer

signal text_changed(new_text)

onready var _line_edit: LineEdit = $LineEdit
onready var _warning: TextureRect = $MarginContainer/Warning


func set_warning(warning: String) -> void:
	if warning.empty():
		_warning.hide()
	else:
		_warning.show()
		_warning.hint_tooltip = "Warning:\n%s" % warning


func set_text(text: String) -> void:
	_line_edit.text = text


func get_text() -> String:
	return _line_edit.text


func _on_LineEdit_text_changed(new_text: String) -> void:
	emit_signal("text_changed", new_text)
