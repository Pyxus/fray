extends Reference
## docstring

#inner classes

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

var actions: Array

var _held_down: bool = false
var _was_held_down: bool = false

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

func _to_string() -> String:
	var string := "("

	for i in len(actions):
		var action := actions[i] as String
		string += action

		if i != len(actions) - 1:
			string += " + "
	string += ")"
	return string

func poll() -> void:
	_held_down = is_pressed()

	if _held_down and not _was_held_down:
		_was_held_down = true
	else:
		_was_held_down = false

func is_aggregate() -> bool:
	return actions.size() > 1

func is_pressed() -> bool:
	for action in actions:
		if not Input.is_action_pressed(action):
			return false
	return true

func is_just_pressed() -> bool:
	return is_pressed() and not _held_down

func is_released() -> bool:
	return not is_pressed() and _was_held_down

#private methods

#signal methods
