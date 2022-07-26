tool
extends "input_inspector.gd"

const ReordableList = preload("res://addons/fray/editor/ui/reordable_list/reordable_list.gd")

onready var _default_input_edit: LineEdit = $"ScrollContainer/PropertyContainer/DefaultInputProperty/DefaultInputEdit"
onready var _conditional_list_container: Container = $"ScrollContainer/PropertyContainer/InputByConditionProperty/PanelContainer/VBoxContainer/ConditionalListContainer"
onready var _conditional_list: ReordableList = $"ScrollContainer/PropertyContainer/InputByConditionProperty/PanelContainer/VBoxContainer/ConditionalListContainer/ConditionalList"

func _setup() -> void:
	_default_input_edit.text = _input_data.default_input

	for condition in _input_data.input_by_condition:
		_add_condition_input_edit(condition, _input_data.input_by_condition[condition])


func _add_condition_input_edit(condition: String = "", input: String = "") -> void:
		var h_box := HBoxContainer.new()
		var key_edit := LineEdit.new()
		var value_edit := LineEdit.new()

		for line_edit in [key_edit, value_edit]:
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line_edit.connect("text_changed", self, "_on_ConditionInput_text_changed")

		h_box.add_child(key_edit)
		h_box.add_child(value_edit)
		_conditional_list.add_item(h_box)

		key_edit.text = condition
		value_edit.text = input


func _on_ConditionInput_text_changed(new_text: String) -> void:
	var input_by_condition := {}
	for control in _conditional_list.get_contents():
		var key: String = control.get_child(0).text
		var value: String = control.get_child(1).text

		if not key.empty():
			_conditional_list_container.show()
			input_by_condition[key] = value
	_input_data.input_by_condition = input_by_condition
	emit_signal("save_request")


func _on_ConditionalList_item_removed(item_content: Control):
	if _conditional_list.is_empty():
		_conditional_list_container.hide()


func _on_DefaultInputEdit_text_changed(new_text: String):
	_input_data.default_input = new_text
	emit_signal("save_request")


func _on_AddConditionalButton_pressed():
	_add_condition_input_edit()
