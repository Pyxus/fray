extends "input_editor.gd"

var _joy_axis_item: TreeItem
var _check_positive_item: TreeItem
var _joy_deadzone_item: TreeItem
var _axis_options_button := OptionButton.new()
var _prev_check_positive: bool
var _prev_deadzone: float

func _init(tree: Tree, input_data: FrayInputNS.FrayInputData).(tree, input_data) -> void:
	var root := _tree.create_item()
	_joy_axis_item = _tree.create_item(root)
	_joy_axis_item.set_text(0, "Axis")
	_joy_axis_item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
	_joy_axis_item.set_custom_draw(1, self, "_draw_axis_options")
	_joy_axis_item.set_tooltip(0, "HELLO")
	
	_tree.add_child(_axis_options_button)
	

	_axis_options_button.get_popup().connect("id_pressed", self, "_on_AxisOptionButtonPopup_id_pressed")
	for axis in range(JOY_AXIS_0, JOY_AXIS_MAX):
		_axis_options_button.add_item("Axis %d: " % axis + Input.get_joy_axis_string(axis), axis)
	
	for i in _axis_options_button.get_item_count():
		var item_id := _axis_options_button.get_item_id(i)
		if item_id == _input_data.axis:
			_axis_options_button.select(i)
			break
	
	_check_positive_item = _tree.create_item(root)
	_check_positive_item.set_text(0, "Check Positive")
	_check_positive_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	_check_positive_item.set_editable(1, true)
	_check_positive_item.set_checked(1, _input_data.check_positive)
	
	_joy_deadzone_item = _tree.create_item(root)
	_joy_deadzone_item.set_text(0, "Deadzone")
	_joy_deadzone_item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	_joy_deadzone_item.set_range_config(1, 0, 1, 0.01)
	_joy_deadzone_item.set_range(1, _input_data.deadzone)
	_joy_deadzone_item.set_editable(1, true)


func update() -> void:
	if _input_data is FrayInputNS.JoyAxisInputBind:
		_prev_check_positive = _check_positive_item.is_checked(1)
		_prev_deadzone = _joy_deadzone_item.get_range(1)

		if _input_data.check_positive != _prev_check_positive:
			_input_data.check_positive = _prev_check_positive
			emit_signal("save_requested")
		
		if _input_data.deadzone != _prev_deadzone:
			_input_data.deadzone = _prev_deadzone
			emit_signal("save_requested")


func _notification(what: int):
	if what == NOTIFICATION_PREDELETE and is_instance_valid(_tree):
		_axis_options_button.queue_free()


func _draw_axis_options(item: TreeItem, rect: Rect2) -> void:
	_axis_options_button.rect_position = rect.position
	_axis_options_button.rect_size.x = rect.size.x


func _on_AxisOptionButtonPopup_id_pressed(id: int) -> void:
	_input_data.axis = id
	emit_signal("save_requested")