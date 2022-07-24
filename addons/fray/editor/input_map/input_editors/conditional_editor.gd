extends "input_editor.gd"

var _default_input_item: TreeItem

func _init(tree: Tree, input_data: FrayInputNS.FrayInputData).(tree, input_data) -> void:
	var root := _tree.create_item()
	_default_input_item = _tree.create_item(root)
	_default_input_item.set_text(0, "Default Input")
	_default_input_item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
	_default_input_item.set_text(1, _input_data.default_input)
	_default_input_item.set_editable(1, true)

	var _key_value_item := _tree.create_item(root)
	_key_value_item.set_text(0, "Input By Condition")
	_key_value_item.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	_key_value_item.set_text(1, "TEST")

	var test := _tree.create_item(_key_value_item)
	test.set_text(0, "ABC")


func update() -> void:
	if _input_data is FrayInputNS.ConditionalInput:
		_input_data.default_input = _default_input_item.get_text(1)
