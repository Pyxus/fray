tool
extends MarginContainer

const FrayConfig = preload("res://addons/fray/fray_config.gd")
const InputInspector = preload("input_inspectors/input_inspector.gd")
const InputList = preload("input_list.gd")

const ActionInspectorScn = preload("input_inspectors/action_inspector.tscn")
const JoyAxisInspectorScn = preload("input_inspectors/joy_axis_inspector.tscn")
const JoyButtonInspectorScn = preload("input_inspectors/joy_button_inspector.tscn")
const MouseButtonInspectorScn = preload("input_inspectors/mouse_button_inspector.tscn")
const KeyInspectorScn = preload("input_inspectors/key_inspector.tscn")
const CombinationInspectorScn = preload("input_inspectors/combination_inspector.tscn")
const ConditionaInspectorScn = preload("input_inspectors/conditional_inspector.tscn")

enum InputType{
	BIND,
	COMBINATION,
	CONDITIONAL
}

enum BindOption{
	ACTION,
	JOY_AXIS,
	JOY_BUTTON,
	KEY,
	MOUSE_BUTTON,
}

var _fray_config := FrayConfig.new()
var _selected_input: String

onready var _input_list: InputList = $"VBoxContainer/HSplitContainer/ScrollContainer/InputList"
onready var _input_name_edit: LineEdit = $"VBoxContainer/HBoxContainer/HBoxContainer/HBoxContainer/InputNameEdit"
onready var _add_input_button: Button = $"VBoxContainer/HBoxContainer/HBoxContainer/AddInputButton"
onready var _error_label: Label = $"VBoxContainer/HBoxContainer/HBoxContainer/ErrorLabel"
onready var _input_type_selector: OptionButton = $"VBoxContainer/HBoxContainer/HBoxContainer/HBoxContainer2/InputTypeSelector"
onready var _select_bind_popup: PopupMenu = $"Control/SelectBindPopup"
onready var _inspector_container: Container = $"VBoxContainer/HSplitContainer/MarginContainer/InspectorContainer"
onready var _current_inspector: InputInspector

func _ready() -> void:
	_load_inputs()

	_select_bind_popup.add_separator("Select Bind")

	for option in BindOption:
		_select_bind_popup.add_item(option.capitalize(), BindOption[option])


func change_inspector(new_inspector: InputInspector, input_data: FrayInputNS.FrayInputData) -> void:
	if is_instance_valid(_current_inspector):
		_current_inspector.queue_free()

	_current_inspector = new_inspector
	_current_inspector.connect("save_request", self, "_on_InputInspector_save_request")
	_inspector_container.add_child(_current_inspector)
	_current_inspector.initialize(input_data)


func save() -> void:
	if  is_instance_valid(_current_inspector):
		_fray_config.save_input(_selected_input, _current_inspector.get_input_data())


func _load_inputs() -> void:
	for input_name in _fray_config.get_input_names():
		var input_data := _fray_config.get_input(input_name)

		if input_data is FrayInputNS.InputBind:
			_input_list.add_bind(input_name)
		elif input_data is FrayInputNS.CombinationInput:
			_input_list.add_combination(input_name)
		elif input_data is FrayInputNS.ConditionalInput:
			_input_list.add_conditional(input_name)


func _add_input(input_name: String, type: int) -> void:
	if _fray_config.has_input(input_name):
		return

	match type:
		InputType.BIND:
			_select_bind_popup.popup()
		InputType.COMBINATION:
			var input_data := FrayInputNS.CombinationInput.new()
			_fray_config.save_input(input_name, input_data)
			_input_list.add_combination(input_name)
			change_inspector(CombinationInspectorScn.instance(), input_data)
			_input_name_edit.clear()
		InputType.CONDITIONAL:
			var input_data := FrayInputNS.ConditionalInput.new()
			_fray_config.save_input(input_name, input_data)
			_input_list.add_conditional(input_name)
			change_inspector(ConditionaInspectorScn.instance(), input_data)
			_input_name_edit.clear()


func _on_InputNameEdit_text_changed(new_text: String):
	if new_text.empty():
		_add_input_button.disabled = true
	elif _fray_config.has_input(new_text):
		_add_input_button.disabled = true
		_error_label.text = "Input '%s' already exists." % new_text
		_error_label.show()
	else:
		_add_input_button.disabled = false
		_error_label.hide()


func _on_InputNameEdit_text_entered(new_text: String):
	_add_input(new_text, _input_type_selector.selected)


func _on_AddInputButton_pressed():
	_add_input(_input_name_edit.text, _input_type_selector.selected)


func _on_SelectBindPopup_id_pressed(id: int):
	var input_name := _input_name_edit.text
	var input_data: FrayInputNS.FrayInputData

	match id:
		BindOption.ACTION:
			input_data = FrayInputNS.ActionInputBind.new()
		BindOption.JOY_AXIS:
			input_data = FrayInputNS.JoyAxisInputBind.new()
		BindOption.JOY_BUTTON:
			input_data = FrayInputNS.JoyButtonInputBind.new()
		BindOption.KEY:
			input_data = FrayInputNS.KeyInputBind.new()
		BindOption.MOUSE_BUTTON:
			input_data = FrayInputNS.MouseInputBind.new()
		_:
			push_error("Unexpected id '%d' selected" % id)
			return

	_input_list.add_bind(input_name)
	_input_name_edit.clear()
	_fray_config.save_input(input_name, input_data)

func _on_InputList_input_selected(input_name: String):
	var input_data := _fray_config.get_input(input_name)
	_selected_input = input_name

	if input_data is FrayInputNS.ActionInputBind:
		change_inspector(ActionInspectorScn.instance(), input_data)
	elif input_data is FrayInputNS.JoyAxisInputBind:
		change_inspector(JoyAxisInspectorScn.instance(), input_data)
	elif input_data is FrayInputNS.JoyButtonInputBind:
		change_inspector(JoyButtonInspectorScn.instance(), input_data)
	elif input_data is FrayInputNS.KeyInputBind:
		change_inspector(KeyInspectorScn.instance(), input_data)
	elif input_data is FrayInputNS.MouseInputBind:
		change_inspector(MouseButtonInspectorScn.instance(), input_data)
	elif input_data is FrayInputNS.CombinationInput:
		change_inspector(CombinationInspectorScn.instance(), input_data)
	elif input_data is FrayInputNS.ConditionalInput:
		change_inspector(ConditionaInspectorScn.instance(), input_data)


func _on_InputList_delete_input_request(input_name: String):
	_input_list.remove_input(input_name)
	_fray_config.delete_input(input_name)


func _on_InputInspector_save_request() -> void:
	save()
