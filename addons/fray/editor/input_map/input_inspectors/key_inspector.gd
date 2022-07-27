tool
extends "input_inspector.gd"

var _scancode: int

onready var _assign_button: Button = $"ScrollContainer/PropertyContainer/ButtonProperty/AssignButton"
onready var _assign_dialog: ConfirmationDialog = $"Control/AssignDialog"


func _ready() -> void:
	var label := _assign_dialog.get_label()
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	_assign_dialog.popup_exclusive = true
	
	_assign_dialog.get_cancel().focus_mode = Control.FOCUS_CLICK
	_assign_dialog.get_ok().focus_mode = Control.FOCUS_CLICK


func _input(event) -> void:
		if event is InputEventKey:
			if event.pressed and visible:
				_scancode = event.scancode
				_assign_dialog.get_ok().disabled = false
				_assign_dialog.dialog_text = OS.get_scancode_string(event.scancode)
		elif event is InputEventMouseButton:
			if event.is_pressed() and not get_global_rect().has_point(event.global_position):
				visible = false


func _setup() -> void:
	_set_assign_button_text(_input_data.key)


func _set_assign_button_text(key: int) -> void:
	if key < 0:
		_assign_button.text = "Assign key..."
	else:
		_assign_button.text = OS.get_scancode_string(key)


func _on_AssignButton_pressed():
	_assign_dialog.popup_centered(Vector2(200, 100))
	_assign_dialog.dialog_text = "Press any key..."
	_assign_dialog.get_ok().disabled = true
	_assign_dialog.get_ok().release_focus()
	_assign_dialog.get_cancel().release_focus()


func _on_AssignDialog_confirmed():
	_set_assign_button_text(_scancode)
	_input_data.key = _scancode
	emit_signal("save_requested")
