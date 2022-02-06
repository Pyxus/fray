extends Resource

const Transition = preload("transitions/transition.gd")
const SituationTransition = preload("transitions/situation_transition.gd")
const Chain = preload("transitions/chain.gd")
const CombatState = preload("combat_state.gd")
const InputData = preload("transitions/input_data/input_data.gd")
const Condition = preload("conditions/condition.gd")
const StringCondition = preload("conditions/string_condition.gd")
var Situation = load("res://addons/stray_combat_framework/src/combat/state_management/situation.gd")

var name: String
var condition_by_name: Dictionary

var _root := CombatState.new()
var _states: Array
var _next_situation_transitions: Array
var _global_chains: Array
var _global_chain_rules: Dictionary
var _associated_states: Array 

func _init() -> void:
    _root.situation = self

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_associated_states.clear()

        
func add_transition_to(situation: Resource, advance_condition: Condition) -> void:
    assert(situation is Situation, "The passed argument is not of type Situation.")
    
    if situation == self:
        push_warning("Failed to add transition to situation. A situation can not transition to it self.")
        return

    if has_transition_to(situation):
        push_error("Failed to add transition to situation. A transition to situation '%s' already exists" % situation)
        return

    var situation_transition := SituationTransition.new()
    situation_transition.advance_condition = advance_condition
    situation_transition.to = situation

    _next_situation_transitions.append(situation_transition)
    _next_situation_transitions.sort_custom(Transition.PrioritySorter, "sort_ascending")


func has_transition_to(situation: Resource) -> bool:
    assert(situation is Situation, "The passed argument is not of type Situation.")

    for situation_transition in _next_situation_transitions:
        if situation_transition.to == situation:
            return true

    return false


func get_next_transition(condition_dict: Dictionary) -> Transition:
    for situation_tranisiton in _next_situation_transitions:
        var condition: Condition = situation_tranisiton.advance_condition
        if condition is StringCondition:
            if condition_dict.has(condition.condition_name) and condition_dict[condition.condition_name]:
                return situation_tranisiton
    return null


func add_global_chain(to_state: CombatState, input_data: InputData, chain_conditions: Array, min_input_delay: float = 0) -> void:
    var chain := Chain.new()
    chain.input_data = input_data
    chain.chain_conditions = chain_conditions
    chain.min_input_delay = min_input_delay

    _global_chains.append(input_data)
    _global_chains.sort_custom(Transition.PrioritySorter, "sort_ascending")


func add_global_transition_rule(from_tag: String, to_tags: PoolStringArray) -> void:
    _global_chain_rules[from_tag] = to_tags
    pass


func associate_state(state: CombatState) -> void:
    if not _associated_states.has(state):
        _associated_states.append(state)
        state.situation = self


func get_global_chains() -> Array:
    return _global_chains

func is_global_chain_rule(from_tag: String, to_tag) -> bool:
    if not _global_chain_rules.has(from_tag):
        return false

    return to_tag in _global_chain_rules[from_tag]


func get_root() -> CombatState:
    return _root