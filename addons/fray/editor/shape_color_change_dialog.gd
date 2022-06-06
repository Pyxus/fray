extends WindowDialog

signal option_selected(is_accepted)

onready var _accept_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/AcceptButton
onready var _deny_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/DenyButton

func _ready() -> void:
	_accept_button.connect("pressed", self, "_on_AcceptButton_pressed")
	_deny_button.connect("pressed", self, "_on_DenyButton_pressed")
	connect("popup_hide", self, "_on_popup_hide")
	
	
func _on_AcceptButton_pressed():
	print("accepted")
	hide()
	emit_signal("option_selected", true)


func _on_DenyButton_pressed():
	print("denied")
	hide()
	emit_signal("option_selected", false)


func _on_popup_hide() -> void:
	emit_signal("option_selected", false)
