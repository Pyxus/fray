extends Reference

signal save_requested()

var _tree: Tree
var _input_data: FrayInputNS.FrayInputData

func _init(tree: Tree, input_data: FrayInputNS.FrayInputData) -> void:
	tree.clear()
	_tree = tree
	_input_data = input_data
	_tree.connect("item_edited", self, "_on_Tree_item_edited")


func update() -> void:
	pass


func _on_Tree_item_edited() -> void:
	emit_signal("save_requested")