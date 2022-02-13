extends "transition.gd"

const Condition = preload("../conditions/condition.gd")

var advance_condition: Condition
var to: Resource setget set_to_situation, get_to_situation

var _to := WeakRef.new()


func set_to_situation(situation: Resource) -> void:
    _to = weakref(situation)


func get_to_situation() -> Resource:
    return _to.get_ref()
