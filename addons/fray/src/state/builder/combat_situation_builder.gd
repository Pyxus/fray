class_name FrayCombatSiutationBuilder
extends FrayStateMachineGlobalBuilder
## Combat situation builder
##
## Global state machine builder that supports input transitions.
## Useful for creating situations for use in a [FrayCombatStateMachine].

const InputTransition = preload("../node/transition/input_transition.gd")
const InputTransitionButton = preload("../node/transition/input_transition_button.gd")
const InputTransitionSequence = preload("../node/transition/input_transition_sequence.gd")

## Creates a new input button transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionButton] properties.
func transition_button(from: StringName, to: StringName, config: Dictionary = {}) -> RefCounted:
	var transition := _create_transition(from, to, InputTransitionButton.new()).transition
	_configure_transition(transition, config)
	return self

## Creates a new inupt sequence transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionSequence] properties.
func transition_sequence(from: StringName, to: StringName, config: Dictionary = {}) -> RefCounted:
	var transition := _create_transition(from, to, InputTransitionSequence.new()).transition
	_configure_transition(transition, config)
	return self


## Creates a new global input button transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionButton] properties.
func transition_button_global(to: StringName, config: Dictionary = {}) -> RefCounted:
	var tr := _create_global_transition(to, InputTransitionButton.new())
	_configure_transition(tr.transition, config)
	return self

## Creates a new global input sequence transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionSequence] properties.
func transition_sequence_global(to: StringName, config: Dictionary = {}) -> RefCounted:
	var tr := _create_global_transition(to, InputTransitionSequence.new())
	_configure_transition(tr.transition, config)
	return self