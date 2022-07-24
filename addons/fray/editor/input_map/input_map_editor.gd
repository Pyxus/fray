tool
extends Control

const FrayConfig = preload("res://addons/fray/fray_config.gd")
const InputEditor = preload("input_editors/input_editor.gd")
const ActionEditor = preload("input_editors/action_editor.gd")
const JoyAxisEditor = preload("input_editors/joy_axis_editor.gd")
const JoyButtonEditor = preload("input_editors/joy_button_editor.gd")
const KeyEditor = preload("input_editors/key_editor.gd")
const MouseButtonEditor = preload("input_editors/mouse_button_editor.gd")
const ConditionalEditor = preload("input_editors/conditional_editor.gd")

const ICON_REMOVE = preload("res://addons/fray/assets/icons/remove.svg")
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
var _current_input_editor: InputEditor
var _current_input_data: FrayInputNS.FrayInputData
var _current_input_name: String
var _editor_has_changes: bool
var _fray_config: FrayConfig

onready var _input_list: Tree = $HBoxContainer/HSplitContainer/ScrollContainer/InputList
onready var _error_label: Label = $HBoxContainer/HBoxContainer/ErrorLabel
onready var _input_name_edit: LineEdit = $HBoxContainer/HBoxContainer/HBoxContainer/InputNameEdit
onready var _input_type_selection: OptionButton = $HBoxContainer/HBoxContainer/HBoxContainer2/InputTypeSelection
onready var _add_input_button: Button = $HBoxContainer/HBoxContainer/AddInputButton
onready var _select_bind_dialog: WindowDialog = $Node/SelectBindDialog
onready var _input_editor_tree: Tree = $HBoxContainer/HSplitContainer/MarginContainer/InputEditorTree


func _ready() -> void:
	_fray_config = FrayConfig.new()
	_input_list.set_column_titles_visible(true)
	_input_list.set_column_title(0, "Inputs")
	_load_input_list()


func _process(delta: float) -> void:
	if _current_input_editor != null:
		_current_input_editor.update()
		

func save() -> void:
	if _current_input_data != null:
		_fray_config.save_input(_current_input_name, _current_input_data)


func _add_input(input_name: String, type: int) -> void:
	var new_item: TreeItem
	match type:
		InputType.BIND:
			new_item = _input_list.create_item(_input_bind_item)
		InputType.COMBINATION:
			new_item = _input_list.create_item(_combination_input_item)
		InputType.CONDITIONAL:
			new_item = _input_list.create_item(_conditiona_input_item)
		_:
			push_error("Failed to add input, unknown type")
			return

	new_item.set_metadata(0, input_name)
	new_item.set_text(0, input_name)
	new_item.add_button(0, ICON_REMOVE)


func _load_input_list() -> void:
	_input_list.clear()

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

	for input_name in _fray_config.get_input_names():
		var input_data := _fray_config.get_input(input_name)

		if input_data is FrayInputNS.InputBind:
			_add_input(input_name, InputType.BIND)


func _on_InputNameEdit_text_changed(new_text: String) -> void:
	if new_text.empty():
		_add_input_button.disabled = true
	elif _fray_config.has_input(new_text):
		_add_input_button.disabled = true
		_error_label.text = "Input '%s' already exists." % new_text
		_error_label.show()
	else:
		_add_input_button.disabled = false
		_error_label.hide()
	pass

func _on_AddInputButton_pressed() -> void:
	match _input_type_selection.selected:
		InputType.BIND:
			_select_bind_dialog.popup_centered_minsize()
		InputType.COMBINATION, InputType.CONDITIONAL:
			_input_name_edit.clear()
	pass

func _on_SelectBindDialog_bind_selected(id: int) -> void:
	
	var input_name := _input_name_edit.text
	var input_data: FrayInputNS.FrayInputData
	
	match id:
		BindOption.ACTION:
			input_data = FrayInputNS.ActionInputBind.new()
		BindOption.JOYSTICK_AXIS:
			input_data = FrayInputNS.JoyAxisInputBind.new()
		BindOption.JOYSTICK_BUTTON:
			input_data = FrayInputNS.JoyButtonInputBind.new()
		BindOption.KEYBOARD:
			input_data = FrayInputNS.KeyInputBind.new()
		BindOption.MOUSE_BUTTON:
			input_data = FrayInputNS.MouseInputBind.new()
		_:
			push_error("Unexpected id '%d' selected" % id)
			return

	_add_input_bind(input_name)
	_input_name_edit.clear()
	_fray_config.save_input(input_name, input_data)


func _on_InputList_item_selected() -> void:
	var selected_item := _input_list.get_selected()
	_current_input_name = selected_item.get_metadata(0)
	_current_input_data = _fray_config.get_input(_current_input_name)

	if _current_input_data is FrayInputNS.ActionInputBind:
		_current_input_editor = ActionEditor.new(_input_editor_tree, _current_input_data)
	elif _current_input_data is FrayInputNS.JoyAxisInputBind:
		_current_input_editor = JoyAxisEditor.new(_input_editor_tree, _current_input_data)
	elif _current_input_data is FrayInputNS.JoyButtonInputBind:
		_current_input_editor = JoyButtonEditor.new(_input_editor_tree, _current_input_data)
	elif _current_input_data is FrayInputNS.KeyInputBind:
		_current_input_editor = KeyEditor.new(_input_editor_tree, _current_input_data)
	elif _current_input_data is FrayInputNS.MouseInputBind:
		_current_input_editor = MouseButtonEditor.new(_input_editor_tree, _current_input_data)
	elif _current_input_data is FrayInputNS.CombinationInput:
		pass
	elif _current_input_data is FrayInputNS.ConditionalInput:
		_current_input_editor = ConditionalEditor.new(_input_editor_tree, _current_input_data)
	pass

	_current_input_editor.connect("save_requested", self, "_on_InputEditor_save_requested")


func _on_InputEditor_save_requested() -> void:
	save()


func _on_InputList_button_pressed(item: TreeItem, column: int, id: int):
	var input_name: String = item.get_metadata(0)
	_fray_config.delete_input(input_name)
	item.free()
