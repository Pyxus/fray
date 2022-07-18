extends Control

enum InputType{
	BIND,
	COMBINATION,
	CONDITIONAL
}

enum BindOption{
	ACTION,
	JOYSTICK_AXIS,
	JOYSTICK_BUTTON,
	KEYBOARD,
	MOUSE_BUTTON,
}

const SelectBindDialog = preload("select_bind_dialog.gd")

var _input_bind_item: TreeItem
var _combination_input_item: TreeItem
var _conditiona_input_item: TreeItem

onready var _input_map: FrayInputNS.FrayInputMap = get_node("/root/FrayInputMap")
onready var _input_list: Tree = $HBoxContainer/HSplitContainer/ScrollContainer/InputList
onready var _error_label: Label = $HBoxContainer/HBoxContainer/ErrorLabel
onready var _input_name_edit: LineEdit = $HBoxContainer/HBoxContainer/HBoxContainer/InputNameEdit
onready var _input_type_selection: OptionButton = $HBoxContainer/HBoxContainer/HBoxContainer2/InputTypeSelection
onready var _add_input_button: Button = $HBoxContainer/HBoxContainer/AddInputButton
onready var _select_bind_dialog: WindowDialog = $Node/SelectBindDialog
onready var _input_editor: Tree = $HBoxContainer/HSplitContainer/PanelContainer/InputEditor

func _ready() -> void:
	_input_list.set_column_titles_visible(true)
	_input_list.set_column_title(0, "Inputs")
	
	var root = _input_list.create_item()
	_input_bind_item = _input_list.create_item(root)
	_input_bind_item.set_text(0, "Binds")
	_input_bind_item.set_selectable(0, false)

	_combination_input_item = _input_list.create_item(root)
	_combination_input_item.set_text(0, "Combinations")
	_combination_input_item.set_selectable(0, false)
	
	_conditiona_input_item = _input_list.create_item(root)
	_conditiona_input_item.set_text(0, "Condtionals")
	_conditiona_input_item.set_selectable(0, false)

	#child1.add_button(0, load("res://addons/dialogue_manager/assets/icons/icon_dark_1.5.svg"))


func _on_InputNameEdit_text_changed(new_text: String) -> void:
	if new_text.empty():
		_add_input_button.disabled = true
	elif _input_map.has_input(new_text):
		_add_input_button.disabled = true
		_error_label.text = "Input '%s' already exists." % new_text
		_error_label.show()
	else:
		_add_input_button.disabled = false
		_error_label.hide()


func _on_AddInputButton_pressed() -> void:
	match _input_type_selection.selected:
		InputType.BIND:
			_select_bind_dialog.popup_centered_minsize()
		InputType.COMBINATION:
			_input_name_edit.clear()
		InputType.CONDITIONAL:
			_input_name_edit.clear()


func _on_SelectBindDialog_bind_selected(id: int) -> void:
	var new_item := _input_list.create_item(_input_bind_item)
	var input_name := _input_name_edit.text
	match id:
		BindOption.ACTION:
			_input_map.add_action_input(input_name)
		BindOption.JOYSTICK_AXIS:
			_input_map.add_joystick_axis_input(input_name)
		BindOption.JOYSTICK_BUTTON:
			_input_map.add_joystick_button_input(input_name)
		BindOption.KEYBOARD:
			_input_map.add_keyboard_input(input_name)
		BindOption.MOUSE_BUTTON:
			_input_map.add_mouse_button_input(input_name)
	var TEST = _input_map.get_input_bind(input_name)
	new_item.set_metadata(0, input_name)
	new_item.set_text(0, input_name)
	_input_name_edit.clear()


func _on_InputList_item_selected() -> void:
	var selected_item := _input_list.get_selected()
	var input_name = selected_item.get_metadata(0)
	
	_input_editor.set_input_data(_input_map.get_input(input_name))
