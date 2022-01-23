extends PanelContainer


var icon_texture: Texture setget set_icon_texture
var input_id: int = -1 setget set_input_id
var id_label_visible: bool setget set_id_label_visible
var icon_visible: bool setget set_icon_visible
var time_stamp: int

onready var _input_icon: TextureRect = get_node("VBoxContainer/InputIcon")
onready var _input_label: Label = get_node("VBoxContainer/InputLabel")


func set_icon_texture(value: Texture) -> void:
	icon_texture = value

	if is_inside_tree():
		_input_icon.texture = icon_texture
	
		if icon_texture == null:
			_input_icon.hide()
		elif icon_visible:
			_input_icon.show()

func set_input_id(value: int) -> void:
	input_id = value

	if is_inside_tree():
		_input_label.text = str(input_id)


func set_id_label_visible(value: bool) -> void:
	id_label_visible = value

	if is_inside_tree():
		_input_label.visible = value


func set_icon_visible(value: bool) -> void:
	icon_visible = value

	if is_inside_tree():
		_input_icon.visible = value