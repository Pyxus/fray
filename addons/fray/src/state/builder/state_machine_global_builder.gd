extends "state_machine_builder.gd"
## Global state machine builder

const GraphNodeStateMachineGlobal = preload("../graph_node/graph_node_state_machine_global.gd")

## Type: Dictionary<String, String[]>
## Hint: <from tag, to tags>
var _transition_rules: Dictionary

## Type: Dictionary<String, String[]>
var _tags_by_state: Dictionary

## Type: InputTransition[]
var _global_transitions: Array


func _build_impl(start_state: String = "") -> GraphNodeStateMachine:
	var root := GraphNodeStateMachineGlobal.new()
	_configure_state_machine(start_state, root)
	return root


func _clear_impl() -> void:
	._clear_impl()
	_transition_rules.clear()
	_tags_by_state.clear()
	_global_transitions.clear()

## Adds a new transition rule to be used by global transitions.
##
## Returns a reference to this builder
func add_rule(from_tag: String, to_tag: String) -> Reference:
	if not _transition_rules.has(from_tag):
		_transition_rules[from_tag] = []
	_transition_rules[from_tag].append(to_tag)
	return self

## Appends given tags onto all given states.
## States used will automatically be added.
##
## Returns a reference to this builder
func tag_multi(states: PoolStringArray, tags: PoolStringArray) -> Reference:
	for state in states:
		tag(state, tags)
	return self

## Appends given tags onto given state.
## States used will automatically be added.
##
## Returns a reference to this builder
func tag(state: String, tags: PoolStringArray) -> Reference:
	add_state(state)
		
	if not _tags_by_state.has(state):
		_tags_by_state[state] = []

	for tag in tags:
		if not _tags_by_state[state].has(tag):
			_tags_by_state[state].append(tag)
	return self

## Creates a new global transtion to the specified state. 
func transition_global(to: String, config: Dictionary = {}) -> Reference:
	var tr := _create_global_transition(to, StateMachineTransition.new())
	_configure_transition(tr.transition, config)
	return self


func _create_global_transition(to: String, transition: StateMachineTransition) -> Transition:
	var tr := Transition.new()
	tr.to = to
	tr.transition = transition
	_global_transitions.append(tr)
	return tr

func _configure_state_machine(start_state: String, root: GraphNodeStateMachine) -> void:
	._configure_state_machine(start_state, root)

	if root is GraphNodeStateMachineGlobal:
		for state in _tags_by_state:
			root.set_node_tags(state, _tags_by_state[state])
		
		for from_tag in _transition_rules:
			for to_tag in _transition_rules[from_tag]:
				root.add_global_transition_rule(from_tag, to_tag)
		
		for g_tr in _global_transitions:
			root.add_global_transition(g_tr.to, g_tr.transition)
