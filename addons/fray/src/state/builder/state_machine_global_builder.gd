class_name FrayStateMachineGlobalBuilder
extends FrayStateMachineBuilder
## Global state machine builder


# Type: Dictionary<StringName, StringName[]>
# Hint: <from tag, to tags>
var _transition_rules: Dictionary

# Type: Dictionary<StringName, StringName[]>
var _tags_by_state: Dictionary

var _global_transitions: Array[FrayInputTransition]


func _build_impl() -> FrayStateNodeStateMachine:
	var root := FrayStateNodeStateMachineGlobal.new()
	_configure_state_machine(root)
	return root


func _clear_impl() -> void:
	super()
	_transition_rules.clear()
	_tags_by_state.clear()
	_global_transitions.clear()

## Adds a new transition rule to be used by global transitions.
## [br]
## Returns a reference to this builder.
func add_rule(from_tag: StringName, to_tag: StringName) -> RefCounted:
	if not _transition_rules.has(from_tag):
		_transition_rules[from_tag] = []
	_transition_rules[from_tag].append(to_tag)
	return self

## Appends given tags onto all given states.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
func tag_multi(states: PackedStringArray, tags: PackedStringArray) -> RefCounted:
	for state in states:
		tag(state, tags)
	return self

## Appends given tags onto given state.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
func tag(state: StringName, tags: PackedStringArray) -> RefCounted:
	_add_state_once(state)
		
	if not _tags_by_state.has(state):
		_tags_by_state[state] = []

	for tag in tags:
		if not _tags_by_state[state].has(tag):
			_tags_by_state[state].append(tag)
	return self

## Creates a new global transtion to the specified state. 
func transition_global(to: StringName, config: Dictionary = {}) -> RefCounted:
	var tr := _create_global_transition(to, FrayStateMachineTransition.new())
	_configure_transition(tr.transition, config)
	return self


func _create_global_transition(to: StringName, transition: FrayStateMachineTransition) -> Transition:
	var tr := Transition.new()
	tr.to = to
	tr.transition = transition
	_global_transitions.append(tr)
	return tr

func _configure_state_machine(root: FrayStateNodeStateMachine) -> void:
	super(root)

	if root is FrayStateNodeStateMachineGlobal:
		for state in _tags_by_state:
			root.set_node_tags(state, _tags_by_state[state])
		
		for from_tag in _transition_rules:
			for to_tag in _transition_rules[from_tag]:
				root.add_global_transition_rule(from_tag, to_tag)
		
		for g_tr in _global_transitions:
			root.add_global_transition(g_tr.to, g_tr.transition)
