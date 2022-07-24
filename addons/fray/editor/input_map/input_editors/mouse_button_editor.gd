extends "input_editor.gd"

var _mouse_button_item: TreeItem
var _mouse_button_options_button := OptionButton.new()
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

func _init(tree: Tree, input_data: FrayInputNS.FrayInputData).(tree, input_data) -> void:
	var root := _tree.create_item()
	
	_mouse_button_item = _tree.create_item(root)
	_mouse_button_item.set_text(0, "Button")
	_mouse_button_item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
	_mouse_button_item.set_custom_draw(1, self, "_draw_mouse_options")
	
	_mouse_button_options_button.get_popup().connect("id_pressed", self, "_on_MouseButtonOptionButtonPopup_id_pressed")

	_tree.add_child(_mouse_button_options_button)
	
	for mouse_button in _mouse_name_by_id:
		_mouse_button_options_button.add_item(_mouse_name_by_id[mouse_button], mouse_button)
	
	for i in _mouse_button_options_button.get_item_count():
		var item_id := _mouse_button_options_button.get_item_id(i)
		if item_id == _input_data.button:
			_mouse_button_options_button.select(i)
			break


func _notification(what: int):
	if what == NOTIFICATION_PREDELETE and is_instance_valid(_tree):
		_mouse_button_options_button.queue_free()


func _draw_mouse_options(item: TreeItem, rect: Rect2) -> void:
	_mouse_button_options_button.rect_position = rect.position
	_mouse_button_options_button.rect_size.x = rect.size.x


func _on_MouseButtonOptionButtonPopup_id_pressed(id: int) -> void:
	_input_data.button =id
	emit_signal("save_requested")