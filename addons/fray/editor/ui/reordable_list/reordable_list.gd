tool
extends PanelContainer

signal item_removed(item_content)
signal reordered()

const ListItem = preload("list_item.gd")
const ListItemScn = preload("list_item.tscn")

var _is_dragging: bool
var _drag_item: ListItem

onready var _item_container: Container = $"ItemContainer"


func _input(event: InputEvent) -> void:
	if _is_dragging and event is InputEventMouseMotion:
		var nearest_y := _drag_item.rect_global_position.y
		var drop_index = _drag_item.get_position_in_parent()

		for item in _item_container.get_children():
			if item != _drag_item:
				var item_y: float = item.rect_global_position.y
				var item_end_y: float = item_y + item.rect_size.y
				var mouse_y: float = event.global_position.y
				if mouse_y > item_y and mouse_y < item_end_y:
					drop_index = item.get_position_in_parent()
					break

		if _drag_item.get_position_in_parent() != drop_index:
			_drag_item.get_parent().move_child(_drag_item, drop_index)



func add_item(content: Control) -> void:
	var new_item: ListItem = ListItemScn.instance()
	_item_container.add_child(new_item)
	new_item.content = content
	_update_order()
	new_item.connect("remove_button_pressed", self, "_on_ListItem_remove_button_pressed", [new_item])
	new_item.connect("grabber_grabbed", self, "_on_ListItem_grabber_grabbed", [new_item])


func get_contents() -> Array:
	var contents := []
	for item in _item_container.get_children():
		contents.append(item.content)
	return contents


func is_empty() -> bool:
	return _item_container.get_child_count() == 0


func _update_order() -> void:
	for item in _item_container.get_children():
		item.set_order(item.get_position_in_parent())
	emit_signal("reordered")

func _on_ListItem_remove_button_pressed(list_item: ListItem) -> void:
	_item_container.remove_child(list_item)
	emit_signal("item_removed", list_item.content)
	list_item.queue_free()


func _on_ListItem_grabber_grabbed(pressed: bool, list_item: ListItem) -> void:
	_drag_item = list_item
	_is_dragging = pressed
	_update_order()
