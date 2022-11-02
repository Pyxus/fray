extends Reference

const Transition = preload("transition/transition.gd")

var inst: Reference
var adjacency_list: Array

func _init(state_inst: Reference) -> void:
    inst = state_inst

func remove_tranisitons_to(to: String) -> void:
    for transition in adjacency_list:
        if transition.to == to:
            adjacency_list.erase(transition)


func rename_transition_to(old_name: String, new_name: String) -> void:
    for transition in adjacency_list:
        if transition.to == old_name:
            transition.to = new_name


func add_transition(transition: Transition) -> void:
    adjacency_list.append(transition)
    adjacency_list.sort_custom(self, "_sort_transitions")


func get_transition(to: String) -> Transition:
    for transition in adjacency_list:
        if transition.to == to:
            return transition
    return null


func remove_transition_to(to: String) -> void:
    for transition in adjacency_list:
        if transition.to == to:
            adjacency_list.erase(transition)

func _sort_transitions(t1: Transition, t2: Transition) -> bool:
    if t1.priority < t2.priority:
        return true
    return false