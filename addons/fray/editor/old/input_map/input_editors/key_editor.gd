extends "input_editor.gd"

var _action_name_item: TreeItem
var _key_assign_button := Button.new()
var _assign_dialog := AssignDialog.new()

func _init(tree: Tree, input_data: FrayInputNS.FrayInputData).(tree, input_data) -> void:
	_tree.add_child(_key_assign_button)
	_key_assign_button.connect("button_down", self, "_on_KeyAssignButton_button_down")
	_set_assign_button_text(input_data.key)
	
	_tree.add_child(_assign_dialog)
	_assign_dialog.connect("confirmed", self, "_on_AssignDialog_confirmed")
	_assign_dialog.window_title = "Please confirm..."
	
	var root := _tree.create_item()
	var keyboard_item := _tree.create_item(root)
	keyboard_item.set_text(0, "Key")
	keyboard_item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
	keyboard_item.set_custom_draw(1, self, "_draw_key_assign_button")
	

func _notification(what: int):
	if what == NOTIFICATION_PREDELETE and is_instance_valid(_tree):
		_assign_dialog.queue_free()
		_key_assign_button.queue_free()
		

func _draw_key_assign_button(item: TreeItem, rect: Rect2) -> void:
	_key_assign_button.rect_position = rect.position
	_key_assign_button.rect_size.x = rect.size.x
	

func _set_assign_button_text(key: int) -> void:
	if key < 0:
		_key_assign_button.text = "Assign key..."
	else:
		_key_assign_button.text = OS.get_scancode_string(key)


func _on_KeyAssignButton_button_down() -> void:
	_assign_dialog.popup_centered(Vector2(200, 100))
	_assign_dialog.dialog_text = "Press any key..."
	_assign_dialog.get_ok().disabled = true
	_assign_dialog.get_ok().release_focus()
	_assign_dialog.get_cancel().release_focus()

func _on_AssignDialog_confirmed() -> void:
	_set_assign_button_text(_assign_dialog.scancode)
	_input_data.key = _assign_dialog.scancode
	emit_signal("save_requested")


class AssignDialog:
	extends ConfirmationDialog
	
	var scancode: int = -1
	
	func _ready() -> void:
		var label := get_label()
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_CENTER
		popup_exclusive = true
		
		get_cancel().focus_mode = Control.FOCUS_CLICK
		get_ok().focus_mode = Control.FOCUS_CLICK

	func _input(event: InputEvent) -> void:
		if event is InputEventKey:
			if event.pressed and visible:
				get_ok().disabled = false
				scancode = event.scancode
				dialog_text = OS.get_scancode_string(event.scancode)
		elif event is InputEventMouseButton:
			if event.is_pressed() and not get_global_rect().has_point(event.global_position):
				visible = false
