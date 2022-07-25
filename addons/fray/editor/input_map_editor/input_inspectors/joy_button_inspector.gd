tool
extends "input_inspector.gd"

onready var _joy_button_selector: OptionButton = $"ScrollContainer/PropertyContainer/ButtonProperty/JoyButtonSelector"


func _setup() -> void:

	_joy_button_selector.get_popup().connect("id_pressed", self, "_on_JoyButtonSelector_Popup_id_pressed")

	for button in range(JOY_BUTTON_0, JOY_BUTTON_MAX):
		_joy_button_selector.add_item("%d: " % button + Input.get_joy_button_string(button), button)
	
	for i in _joy_button_selector.get_item_count():
		var item_id := _joy_button_selector.get_item_id(i)
		if item_id == _input_data.button:
			_joy_button_selector.select(i)
			break


func _on_JoyButtonSelector_Popup_id_pressed(id: int) -> void:
	_input_data.button = id
	emit_signal("save_request")