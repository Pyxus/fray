extends "input_editor.gd"

var _action_name_item: TreeItem
var _prev_action: String

func _init(tree: Tree, input_data: FrayInputNS.FrayInputData).(tree, input_data) -> void:
	var root := _tree.create_item()
	_action_name_item = _tree.create_item(root)
	_action_name_item.set_text(0, "Action")
	_action_name_item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
	_action_name_item.set_text(1, _input_data.action)
	_action_name_item.set_editable(1, true)


func update() -> void:
	if _input_data is FrayInputNS.ActionInputBind:
		_prev_action = _action_name_item.get_text(1)
		if _input_data.action != _prev_action:
			_input_data.action = _prev_action
			emit_signal("save_requested")