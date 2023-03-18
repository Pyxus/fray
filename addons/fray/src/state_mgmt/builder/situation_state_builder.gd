class_name FraySituationStateBuilder
extends FrayRootStateBuilder
## Combat situation builder
##
## Global state machine builder that supports input transitions.
## Useful for creating situations for use in a [FrayCombatStateMachine].


func _build_impl() -> FrayRootState:
	var root := FraySituationState.new()
	_configure_state_machine_impl(root)
	return root

func build_situation() -> FraySituationState:
	return _build_impl() as FraySituationState

## Creates a new input button transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionButton] properties.
func transition_button(from: StringName, to: StringName, config: Dictionary = {}) -> FraySituationStateBuilder:
	var transition := _create_transition(from, to, FrayInputTransitionButton.new()).transition
	_configure_transition(transition, config)
	return self

## Creates a new inupt sequence transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionSequence] properties.
func transition_sequence(from: StringName, to: StringName, config: Dictionary = {}) -> FraySituationStateBuilder:
	var transition := _create_transition(from, to, FrayInputTransitionSequence.new()).transition
	_configure_transition(transition, config)
	return self


## Creates a new global input button transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionButton] properties.
func transition_button_global(to: StringName, config: Dictionary = {}) -> FraySituationStateBuilder:
	var tr := _create_global_transition(to, FrayInputTransitionButton.new())
	_configure_transition(tr.transition, config)
	return self

## Creates a new global input sequence transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionSequence] properties.
func transition_sequence_global(to: StringName, config: Dictionary = {}) -> FraySituationStateBuilder:
	var tr := _create_global_transition(to, FrayInputTransitionSequence.new())
	_configure_transition(tr.transition, config)
	return self
