extends "input_bind.gd"
## Fray action input bind
##
## @desc:
##		Bind that makes use of simple binds in a way that mimic's Godot's actions.

var _binds: Array

func _init(binds: Array = []) -> void:
	for bind in binds:
		add_bind(bind)


func _is_pressed_impl(device: int = 0) -> bool:
	for bind in _binds:
		if bind.is_pressed(device):
			return true
	return false


func add_bind(simple_bind: Resource) -> void:
	_binds.append(simple_bind)


func erase_bind(simple_bind: Resource) -> void:
	_binds.erase(simple_bind)
