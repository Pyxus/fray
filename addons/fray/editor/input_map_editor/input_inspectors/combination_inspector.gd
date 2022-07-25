tool
extends "input_inspector.gd"


const ReordableList = preload("res://addons/fray/editor/ui/reordable_list/reordable_list.gd")

onready var _mode_selector: OptionButton = $"ScrollContainer/PropertyContainer/ModeProperty/ModeSelector"
onready var _press_hcor_check_box: CheckBox = $"ScrollContainer/PropertyContainer/PressHCORProperty/PressHCORCheckBox"
onready var _component_list: ReordableList = $"ScrollContainer/PropertyContainer/ComponentsProperty/VBoxContainer/ComponentList"
onready var _add_component_button: Button = $"ScrollContainer/PropertyContainer/ComponentsProperty/VBoxContainer/AddComponentButton"

func _setup() -> void:
	var Mode := FrayInputNS.CombinationInput.Mode
	
	_mode_selector.get_popup().connect("id_pressed", self, "_on_ModeSelector_Popup_id_pressed")
	
	for mode in Mode:
		_mode_selector.add_item(mode.capitalize(), Mode[mode])
	
	for i in _mode_selector.get_item_count():
		var item_id := _mode_selector.get_item_id(i)
		if item_id == _input_data.mode:
			_mode_selector.select(i)
			break
	
	for input in _input_data.components:
		_add_component_edit(input)
	
	_press_hcor_check_box.pressed = _input_data.press_held_components_on_release


func _save_components() -> void:
	var components := []
	for line_edit in _component_list.get_contents():
		var component: String = line_edit.text
		if not component.empty():
			components.append(component)
	_input_data.components = components
	emit_signal("save_request")


func _add_component_edit(input: String = "") -> void:
	var line_edit := LineEdit.new()
	line_edit.connect("text_changed", self, "_on_ComponentEdit_text_changed")
	_component_list.add_item(line_edit)
	line_edit.text = input
	_component_list.show()


func _on_ModeSelector_Popup_id_pressed(id: int) -> void:
	_input_data.mode = id
	emit_signal("save_request")


func _on_PressHCORCheckBox_pressed():
	 _input_data.press_held_components_on_release = _press_hcor_check_box.pressed
	 emit_signal("save_request")


func _on_AddComponentButton_pressed():
	_add_component_edit()


func _on_ComponentList_item_removed(item_content: Control):
	if _component_list.is_empty():
		_component_list.hide()


func _on_ComponentEdit_text_changed(new_text: String) -> void:
	_save_components()


func _on_ComponentList_reordered():
	_save_components()
