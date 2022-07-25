tool
extends "input_inspector.gd"

var _mouse_name_by_id := {
	BUTTON_LEFT : "Left Button",
	BUTTON_RIGHT : "Right Button",
	BUTTON_MIDDLE : "Middle Button",
	BUTTON_WHEEL_UP : "Wheel Up",
	BUTTON_WHEEL_DOWN : "Wheel Down",
	BUTTON_WHEEL_LEFT : "Wheel Left",
	BUTTON_WHEEL_RIGHT : "Wheel Right",
	BUTTON_XBUTTON1 : "Extra Button 1",
	BUTTON_XBUTTON2 : "Extra Button 2",
}

onready var _button_selector: OptionButton = $"ScrollContainer/PropertyContainer/ButtonProperty/ButtonSelector"


func _setup() -> void:
	_button_selector.get_popup().connect("id_pressed", self, "_on_ButtonSelector_Popup_id_pressed")

	for mouse_button in _mouse_name_by_id:
		_button_selector.add_item(_mouse_name_by_id[mouse_button], mouse_button)
	
	for i in _button_selector.get_item_count():
		var item_id := _button_selector.get_item_id(i)
		if item_id == _input_data.button:
			_button_selector.select(i)
			break


func _on_ButtonSelector_Popup_id_pressed(id: int) -> void:
	_input_data.button = id
	emit_signal("save_request")