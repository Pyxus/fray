extends Resource

const CombatTreeTransition = preload("transitions/combat_tree_transition.gd")
const Chain = preload("transitions/chain.gd")
const CombatState = preload("combat_state.gd")
const InputData = preload("transitions/input_data/input_data.gd")
const Condition = preload("conditions/condition.gd")
const StringCondition = preload("conditions/string_condition.gd")
var CombatTree = load("res://addons/stray_combat_framework/src/combat/state_management/combat_tree.gd")

var name: String

var _root := CombatState.new()
var _next_tree_transitions: Array
var _associated_states: Array 

var _global_chains: Array 
var _global_chain_rules: Dictionary


func _init() -> void:
	_root.tree = self

	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_associated_states.clear()

	   
func add_transition_to(combat_tree: Resource, advance_condition: Condition) -> void:
	assert(combat_tree is CombatTree, "The passed argument is not of type CombatTree.")
	
	if combat_tree == self:
		push_warning("Failed to add transition to combat tree. A combat tree can not transition to it self.")
		return

	if has_transition_to(combat_tree):
		push_error("Failed to add transition to combat tree. A transition to combat tree '%s' already exists" % combat_tree)
		return

	var transition := CombatTreeTransition.new()
	transition.advance_condition = advance_condition
	transition.to = combat_tree

	_next_tree_transitions.append(transition)
	_next_tree_transitions.sort_custom(CombatTreeTransition.PrioritySorter, "sort_ascending")


func has_transition_to(combat_tree: Resource) -> bool:
	assert(combat_tree is CombatTree, "The passed argument is not of type CombatTree.")

	for tree_transition in _next_tree_transitions:
		if tree_transition.to == combat_tree:
			return true

	return false


func get_next_transition(condition_dict: Dictionary) -> CombatTreeTransition:
	for tree_transition in _next_tree_transitions:
		var condition: Condition = tree_transition.advance_condition
		if condition is StringCondition:
			if condition_dict.has(condition.condition_name) and condition_dict[condition.condition_name]:
				return tree_transition
	return null


func add_global_chain_to(to_state: CombatState, input_data: InputData, chain_conditions: Array = [], min_input_delay: float = 0) -> void:
	var chain := Chain.new()
	chain.to = to_state
	chain.input_data = input_data
	chain.chain_conditions = chain_conditions
	chain.min_input_delay = min_input_delay

	associate_state(to_state)
	_global_chains.append(chain)
	_global_chains.sort_custom(Chain.PrioritySorter, "sort_ascending")


func add_global_transition_rule(from_tag: String, to_tags: PoolStringArray) -> void:
	_global_chain_rules[from_tag] = to_tags
	pass


func associate_state(state: CombatState) -> void:
	if not _associated_states.has(state):
		_associated_states.append(state)
		state.tree = self


func get_global_chains() -> Array:
	return _global_chains

func is_global_chain_rule(from_tag: String, to_tag) -> bool:
	if not _global_chain_rules.has(from_tag):
		return false

	return to_tag in _global_chain_rules[from_tag]


func get_root() -> CombatState:
	return _root
