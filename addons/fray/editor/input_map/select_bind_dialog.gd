extends WindowDialog

signal bind_selected(id)

onready var list: ItemList = $ItemList

func _on_ItemList_item_selected(index: int) -> void:
	emit_signal("bind_selected", index)
	hide()
