extends "condition.gd"

var condition_name: String


func _init(condition_name: String = "") -> void:
	self.condition_name = condition_name
	