class_name FrayCombatSiutationBuilder
extends FrayStateMachineGlobalBuilder
## Combat situation builder
##
## Global state machine builder that supports input transitions.
## Useful for creating situations for use in a [FrayCombatStateMachine].


## Creates a new input button transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionButton] properties.
func transition_button(from: StringName, to: StringName, config: Dictionary = {}) -> FrayCombatSiutationBuilder:
	var transition := _create_transition(from, to, FrayInputTransitionButton.new()).transition
	_configure_transition(transition, config)
	return self

## Creates a new inupt sequence transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionSequence] properties.
func transition_sequence(from: StringName, to: StringName, config: Dictionary = {}) -> FrayCombatSiutationBuilder:
	var transition := _create_transition(from, to, FrayInputTransitionSequence.new()).transition
	_configure_transition(transition, config)
	return self


## Creates a new global input button transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionButton] properties.
func transition_button_global(to: StringName, config: Dictionary = {}) -> FrayCombatSiutationBuilder:
	var tr := _create_global_transition(to, FrayInputTransitionButton.new())
	_configure_transition(tr.transition, config)
	return self

## Creates a new global input sequence transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionSequence] properties.
func transition_sequence_global(to: StringName, config: Dictionary = {}) -> FrayCombatSiutationBuilder:
	var tr := _create_global_transition(to, FrayInputTransitionSequence.new())
	_configure_transition(tr.transition, config)
	return self