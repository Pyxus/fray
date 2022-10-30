extends "state_machine_builder.gd"

const StateCombatSituation = preload("../state/state_combat_situation.gd")
const TransitionInput = preload("../state/transition/transition_input.gd")
const TransitionInputButton = preload("../state/transition/transition_input_button.gd")
const TransitionInputSequence = preload("../state/transition/transition_input_sequence.gd")

## Type: Dictionary<String, String[]>
## Hint: <from tag, to tags>
var _transition_rules: Dictionary

## Type: Dictionary<String, String[]>
var _tags_by_state: Dictionary

## Type: TransitionInput[]
var _global_transitions: Array

func build(start_state: String = "") -> StateCombatSituation:
	var root := StateCombatSituation.new()
	_configure_state_machine(start_state, root)
	return root

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

## Creates a new input button transition from one state to another.
## States used will automatically be added.
##
## Returns a reference to this CombatStateMachineBuilder
func transition_button(from: String, to: String, input: String, config: Dictionary = {}) -> Reference:
	var transition := TransitionInputButton.new()
	_configure_transition_input_button(to, transition, input, config)
	_adjacency_by_state[from].append(transition)
	return self

## Creates a new inupt sequence transition from one state to another.
## States used will automatically be added.
##
## Returns a reference to this CombatStateMachineBuilder
func transition_sequence(from: String, to: String, input: String, config: Dictionary = {}) -> Reference:
	var transition := TransitionInputSequence.new()
	_configure_transition_input_sequence(to, transition, input, config)
	_adjacency_by_state[from].append(transition)
	return self

## Creates a new global input button transition from one state to another.
## States used will automatically be added.
##
## Returns a reference to this CombatStateMachineBuilder
func transition_button_global(to: String, input: String, config: Dictionary = {}) -> Reference:
	var transition := TransitionInputButton.new()
	_configure_transition_input_button(to, transition, input, config)
	_global_transitions.append(transition)
	return self

## Creates a new global input sequence transition from one state to another.
## States used will automatically be added.
##
## Returns a reference to this CombatStateMachineBuilder
func transition_sequence_global(to: String, input: String, config: Dictionary = {}) -> Reference:
	var transition := TransitionInputSequence.new()
	_configure_transition_input_sequence(to, transition, input, config)
	_global_transitions.append(transition)
	return self


func clear() -> void:
	.clear()
	_transition_rules.clear()
	_tags_by_state.clear()
	_global_transitions.clear()


func _configure_state_machine(start_state: String, root: StateCommpound) -> void:
	._configure_state_machine(start_state, root)

	if root is StateCombatSituation:
		for state in _tags_by_state:
			root.set_state_tags(state, _tags_by_state[state])
		
		for from_tag in _transition_rules:
			for to_tag in _transition_rules[from_tag]:
				root.add_global_transition_rule(from_tag, to_tag)
		
		for global_transition in _global_transitions:
			root.add_global_transition(global_transition)


func _configure_transition_input( to: String, transition: TransitionInput, config: Dictionary) -> void:
	_configure_transition(to, transition, config)
	transition.min_input_delay = config.get("min_input_delay", 0)


func _configure_transition_input_button(
	to: String, transition: TransitionInputButton, input: String, config: Dictionary) -> void:
	_configure_transition_input(to, transition, config)
	transition.input = input
	transition.is_triggered_on_release = config.get("is_triggered_on_release", false)


func _configure_transition_input_sequence(
	to: String, transition: TransitionInputSequence, input: String, config: Dictionary) -> void:
	_configure_transition_input(to, transition, config)
	transition.sequence_name = input
	transition.min_input_delay = config.get("min_input_delay", 0)
	