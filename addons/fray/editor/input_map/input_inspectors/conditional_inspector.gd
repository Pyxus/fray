tool
extends "input_inspector.gd"

const ReordableList = preload("res://addons/fray/editor/ui/reordable_list/reordable_list.gd")
const WarningLineEdit = preload("res://addons/fray/editor/ui/warning_line_edit/warning_line_edit.gd")
const WarningLineEditorScn = preload("res://addons/fray/editor/ui/warning_line_edit/warning_line_edit.tscn")
const FrayConfig = preload("res://addons/fray/fray_config.gd")

var _global = load("res://addons/fray/editor/global.tres")

onready var _default_input_edit: LineEdit = $ScrollContainer/PropertyContainer/DefaultInputProperty/MarginContainer2/DefaultInputEdit
onready var _conditional_list_container: Container = $"ScrollContainer/PropertyContainer/InputByConditionProperty/PanelContainer/VBoxContainer/ConditionalListContainer"
onready var _conditional_list: ReordableList = $"ScrollContainer/PropertyContainer/InputByConditionProperty/PanelContainer/VBoxContainer/ConditionalListContainer/ConditionalList"
onready var _default_input_warning: TextureRect = $ScrollContainer/PropertyContainer/DefaultInputProperty/MarginContainer/Warning

func _process(delta: float) -> void:
	var inputs = _global.fray_config.get_input_names()
	var default_input := _default_input_edit.text
	
	if not default_input in inputs:
		_default_input_warning.hint_tooltip = "Warning:\nFray input named '%s' does not exist." % default_input
		_default_input_warning.show()
	elif default_input == _input_name:
		_default_input_warning.hint_tooltip = "Warning:\nA conditional input can not include it self as a component"
		_default_input_warning.show()
	else:
		_default_input_warning.hide()
	
	for control in _conditional_list.get_contents():
		var value_edit: WarningLineEdit = control.get_child(1)
		var component: String = value_edit.get_text()
		if not component in inputs:
			value_edit.set_warning("Fray input named '%s' does not exist." % component)
		elif component == _input_name:
			value_edit.set_warning("A conditional input can not include it self as a component")
		else:
			value_edit.set_warning("")
	

func _setup() -> void:
	_default_input_edit.text = _input_data.default_input

	for condition in _input_data.input_by_condition:
		_add_condition_input_edit(condition, _input_data.input_by_condition[condition])


func _add_condition_input_edit(condition: String = "", input: String = "") -> void:
		var h_box := HBoxContainer.new()
		var key_edit := LineEdit.new()
		var value_edit: WarningLineEdit = WarningLineEditorScn.instance()

		for line_edit in [key_edit, value_edit]:
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line_edit.connect("text_changed", self, "_on_ConditionInput_text_changed")

		h_box.add_child(key_edit)
		h_box.add_child(value_edit)
		_conditional_list.add_item(h_box)

		key_edit.text = condition
		value_edit.set_text(input)


func _on_ConditionInput_text_changed(new_text: String) -> void:
	var input_by_condition := {}
	for control in _conditional_list.get_contents():
		var key: String = control.get_child(0).text
		var value: String = control.get_child(1).get_text()

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
