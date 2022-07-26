tool
extends Tree

signal input_selected(input_name)
signal delete_input_request(input_name)

const ICON_REMOVE = preload("res://addons/fray/assets/icons/remove.svg")

var _bind_section: TreeItem
var _combination_section: TreeItem
var _conditional_section: TreeItem
var _global = load("res://addons/fray/editor/global.tres")

func _ready() -> void:
	var root = create_item()
	_bind_section = create_item(root)
	_bind_section.set_text(0, "Binds")
	_bind_section.set_selectable(0, false)
	_bind_section.set_custom_bg_color(0, _global.base_color)

	_combination_section = create_item(root)
	_combination_section.set_text(0, "Combinations")
	_combination_section.set_selectable(0, false)
	_combination_section.set_custom_bg_color(0, _global.base_color)

	_conditional_section = create_item(root)
	_conditional_section.set_text(0, "Conditionals")
	_conditional_section.set_selectable(0, false)
	_conditional_section.set_custom_bg_color(0, _global.base_color)

	set_column_titles_visible(true)
	set_column_title(0, "Inputs")

	connect("item_selected", self, "_on_item_selected")
	connect("button_pressed", self, "_on_button_pressed")


func _notification(what: int) -> void:
	if _bind_section:
		match what:
			NOTIFICATION_THEME_CHANGED:
				_bind_section.set_custom_bg_color(0, _global.base_color)
				_combination_section.set_custom_bg_color(0, _global.base_color)
				_conditional_section.set_custom_bg_color(0, _global.base_color)
	
	
func add_bind(input_name: String) -> void:
	_add_input(input_name, _bind_section)


func add_combination(input_name: String) -> void:
	_add_input(input_name, _combination_section)


func add_conditional(input_name: String) -> void:
	_add_input(input_name, _conditional_section)


func remove_input(input_name: String) -> void:
	for section in [_bind_section, _combination_section, _conditional_section]:
		var next_item: TreeItem = section.get_children()

		while next_item != null:
			if next_item.get_metadata(0) == input_name:
				next_item.free()
				return

			next_item = next_item.get_next()

func _add_input(input_name: String, section: TreeItem) -> void:
	var new_item := create_item(section)
	new_item.set_metadata(0, input_name)
	new_item.set_text(0, input_name)
	new_item.add_button(0, ICON_REMOVE)


func _on_item_selected() -> void:
	var selected_item := get_selected()
	var input_name: String = selected_item.get_metadata(0)

	emit_signal("input_selected", input_name)


func _on_button_pressed(item: TreeItem, column: int, id: int) -> void:
	var input_name: String = item.get_metadata(0)
	emit_signal("delete_input_request", input_name)
