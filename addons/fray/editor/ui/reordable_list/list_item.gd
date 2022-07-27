tool
extends HBoxContainer

signal remove_button_pressed()
signal grabber_grabbed(pressed)

var content: Control setget set_content

onready var _content_container: Container = $"ContentContainer"
onready var _order_label: Label = $"HBoxContainer/OrderLabel"


func set_order(pos: int) -> void:
	_order_label.text = str(pos)


func set_content(control: Control) -> void:
	content = control

	if content.is_inside_tree():
		content.get_parent().remove_child(content)

	_content_container.add_child(content)

func _on_RemovalButton_pressed():
	emit_signal("remove_button_pressed")


func _on_Grabber_button_up():
	emit_signal("grabber_grabbed", false)


func _on_Grabber_button_down():
	emit_signal("grabber_grabbed", true)
