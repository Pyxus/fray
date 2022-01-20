extends Reference

var _actions: Array
var _held_down: bool
var _previously_held_down: bool


func _to_string() -> String:
	var string := "("
	var action_count = len(_actions)

	for i in action_count:
		var action := _actions[i] as String
		string += action

		if i != action_count - 1:
			string += " + "
	string += ")"
	return string


func poll() -> void:
	_held_down = is_pressed()

	if _held_down and not _previously_held_down:
		_previously_held_down = true
	else:
		_previously_held_down = false


func add_action(action: String) -> void:
	if not InputMap.has_action(action):
		push_warning("Godot input map does not contain action '%s'." % action)
	
	if not _actions.has(action):
		_actions.append(action)

func remove_action(action: String) -> void:
	if _actions.has(action):
		_actions.erase(action)


func get_actions() -> PoolStringArray:
	return PoolStringArray(_actions)


func is_pressed() -> bool:
	for action in _actions:
		if not Input.is_action_pressed(action):
			return false
	return true


func is_just_pressed() -> bool:
	return is_pressed() and not _held_down


func is_released() -> bool:
	return not is_pressed() and _previously_held_down


func is_combination() -> bool:
	return _actions.size() > 1
