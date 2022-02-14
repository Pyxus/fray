extends "transition.gd"

const Condition = preload("../conditions/condition.gd")

var advance_condition: Condition
var to: Resource setget set_to_combat_tree, get_to_combat_tree

var _to := WeakRef.new()


func set_to_combat_tree(combat_tree: Resource) -> void:
    _to = weakref(combat_tree)


func get_to_combat_tree() -> Resource:
    return _to.get_ref()
