extends "input_editor.gd"

var _joy_button_item: TreeItem
var _joy_button_options_button := OptionButton.new()

func _init(tree: Tree, input_data: FrayInputNS.FrayInputData).(tree, input_data) -> void:
	var root := _tree.create_item()
	_joy_button_item = _tree.create_item(root)
	_joy_button_item.set_text(0, "Button")
	_joy_button_item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
	_joy_button_item.set_custom_draw(1, self, "_draw_button_options")
	
	_tree.add_child(_joy_button_options_button)
	
	_joy_button_options_button.get_popup().connect("id_pressed", self, "_on_JoyButtonOptionButtonPopup_id_pressed")

	for button in range(JOY_BUTTON_0, JOY_BUTTON_MAX):
		_joy_button_options_button.add_item("%d: " % button + Input.get_joy_button_string(button), button)
	
	for i in _joy_button_options_button.get_item_count():
		var item_id := _joy_button_options_button.get_item_id(i)
		if item_id == _input_data.button:
			_joy_button_options_button.select(i)
			break


func _notification(what: int):
	if what == NOTIFICATION_PREDELETE and is_instance_valid(_tree):
		_joy_button_options_button.queue_free()


func _draw_button_options(item: TreeItem, rect: Rect2) -> void:
	_joy_button_options_button.rect_position = rect.position
	_joy_button_options_button.rect_size.x = rect.size.x


func _on_JoyButtonOptionButtonPopup_id_pressed(id: int) -> void:
	_input_data.button = id
	emit_signal("save_requested")