extends Tree



var _input_data: FrayInputNS.FrayInputData

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

var _root := create_item()
var _editor_state: Dictionary
var _axis_options_button := OptionButton.new()
var _joy_button_options_button := OptionButton.new()
var _mouse_button_options_button := OptionButton.new()
var _keyboard_assign_button := Button.new()
var _keyboard_assign_dialog := ConfirmationDialog.new()


func _ready() -> void:
	connect("item_custom_button_pressed", self, "_on_item_custom_button_pressed")
	connect("custom_popup_edited", self, "_on_custom_popup_edited")
	connect("button_pressed", self, "_on_button_pressed")
	
	add_child(_keyboard_assign_dialog)
	_keyboard_assign_dialog.window_title = "Please confirm..."
	
	add_child(_keyboard_assign_button)
	_keyboard_assign_button.connect("button_down", self, "_on_KeyboardAssignButton_button_down")
	_keyboard_assign_button.hide()
	
	add_child(_axis_options_button)
	for axis in range(JOY_AXIS_0, JOY_AXIS_MAX):
		_axis_options_button.add_item("Axis %d: " % axis + Input.get_joy_axis_string(axis), axis)
	_axis_options_button.hide()
	
	add_child(_joy_button_options_button)
	for button in range(JOY_BUTTON_0, JOY_BUTTON_MAX):
		_joy_button_options_button.add_item("%d: " % button + Input.get_joy_button_string(button), button)
	_joy_button_options_button.hide()
	
	add_child(_mouse_button_options_button)
	for mouse_button in _mouse_name_by_id:
		_mouse_button_options_button.add_item(_mouse_name_by_id[mouse_button], mouse_button)
	_mouse_button_options_button.hide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and _keyboard_assign_dialog.visible:
			print(event.scancode)
			

func _process(delta: float) -> void:
	if _input_data != null:
		if _input_data is FrayInputNS.InputBind:
			if _input_data is FrayInputNS.ActionInputBind:
				pass
			elif _input_data is FrayInputNS.JoystickAxisInputBind:
				pass
			elif _input_data is FrayInputNS.JoystickButtonInputBind:
				pass
			elif _input_data is FrayInputNS.KeyboardInputBind:
				pass
			elif _input_data is FrayInputNS.MouseInputBind:
				pass
		elif _input_data is FrayInputNS.CombinationInput:
			pass
		elif _input_data is FrayInputNS.ConditionalInput:
			pass
	
	
func set__input_data(data: FrayInputNS.FrayInputData) -> void:
	clear_tree()
	_input_data = data
	
	if _input_data is FrayInputNS.ActionInputBind:
		var action_name_item := create_item(_root)
		action_name_item.set_text(0, "Action")
		action_name_item.set_text(1, _input_data.action)
		action_name_item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
		action_name_item.set_editable(1, true)
		_editor_state = {"action" : action_name_item} 
		#NOTE: Either redesign for 4.0 or replace with lambda
	elif _input_data is FrayInputNS.JoystickAxisInputBind:
		var joy_axis_item := create_item(_root)
		joy_axis_item.set_text(0, "Axis")
		joy_axis_item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
		joy_axis_item.set_custom_draw(1, self, "_draw_axis_options")
		_axis_options_button.show()
		
		for i in _axis_options_button.get_item_count():
			var item_id := _axis_options_button.get_item_id(i)
			if item_id == _input_data.axis:
				_axis_options_button.select(i)
				break
		
		var check_positive_item := create_item(_root)
		check_positive_item.set_text(0, "Check Positive")
		check_positive_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		check_positive_item.set_editable(1, true)
		check_positive_item.set_checked(1, _input_data.check_positive)
		
		var joy_deadzone_item := create_item(_root)
		joy_deadzone_item.set_text(0, "Deadzone")
		joy_deadzone_item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		joy_deadzone_item.set_range_config(1, 0, 1, 0.01)
		joy_deadzone_item.set_range(1, _input_data.deadzone)
		joy_deadzone_item.set_editable(1, true)
		
		_editor_state = {
			"joy_deadzone" : joy_deadzone_item,
			"check_positive" : check_positive_item,
		}
	elif _input_data is FrayInputNS.JoystickButtonInputBind:
		var joy_button_item := create_item(_root)
		joy_button_item.set_text(0, "Button")
		joy_button_item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
		joy_button_item.set_custom_draw(1, self, "_draw_button_options")
		
		for i in _joy_button_options_button.get_item_count():
			var item_id := _joy_button_options_button.get_item_id(i)
			if item_id == _input_data.button:
				_joy_button_options_button.select(i)
				break
	elif _input_data is FrayInputNS.KeyboardInputBind:
		var keyboard_item := create_item(_root)
		keyboard_item.set_text(0, "Key")
		keyboard_item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
		keyboard_item.set_custom_draw(1, self, "_draw_keyboard_assign_button")
		_keyboard_assign_button.text = "Assign key..."
	elif _input_data is FrayInputNS.MouseInputBind:
		var mouse_button_item := create_item(_root)
		mouse_button_item.set_text(0, "Button")
		mouse_button_item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
		mouse_button_item.set_custom_draw(1, self, "_draw_mouse_options")
		
		for i in _mouse_button_options_button.get_item_count():
			var item_id := _mouse_button_options_button.get_item_id(i)
			if item_id == _input_data.button:
				_mouse_button_options_button.select(i)
				break


func clear_tree():
	var item := _root.get_children()
	while item != null:
		var prev_item := item
		item = item.get_next()
		prev_item.free()

	_joy_button_options_button.hide()
	_axis_options_button.hide()

func _on_item_custom_button_pressed() -> void:
	print("HOW")


func _on_custom_popup_edited(arrow_clicked: bool) -> void:
	#print(arrow_clicked)
	print(get_custom_popup_rect())


func _on_button_pressed(item: TreeItem, column: int, id: int) -> void:
	print("ITGMA")


func _draw_axis_options(item: TreeItem, rect: Rect2) -> void:
	_axis_options_button.rect_position = rect.position
	_axis_options_button.rect_size.x = rect.size.x
	_axis_options_button.show()


func _draw_button_options(item: TreeItem, rect: Rect2) -> void:
	_joy_button_options_button.rect_position = rect.position
	_joy_button_options_button.rect_size.x = rect.size.x
	_joy_button_options_button.show()


func _draw_mouse_options(item: TreeItem, rect: Rect2) -> void:
	_mouse_button_options_button.rect_position = rect.position
	_mouse_button_options_button.rect_size.x = rect.size.x
	_mouse_button_options_button.show()


func _draw_keyboard_assign_button(item: TreeItem, rect: Rect2) -> void:
	_keyboard_assign_button.rect_position = rect.position
	_keyboard_assign_button.rect_size.x = rect.size.x
	_keyboard_assign_button.show()
	
	
func _on_KeyboardAssignButton_button_down() -> void:
	_keyboard_assign_dialog.popup_centered(Vector2(200, 100))
