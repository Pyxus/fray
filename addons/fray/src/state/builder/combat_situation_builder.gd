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
##
## `config` is a dictionary used to configure transition options:
##		`input: String`
##		`min_input_delay: float`
##		`advance_conditions: Condition[]`
##		`prereqs: Condition[]`
##		`auto_advance: bool`
##		`priority: int`
##		`switch_mode: int`
##
## Returns a reference to this builder
func transition_button(from: String, to: String, config: Dictionary = {}) -> RefCounted:
	var transition := _create_transition(from, to, InputTransitionButton.new()).transition
	_configure_transition_input_button(transition, config)
	return self

## Creates a new inupt sequence transition from one state to another.
## States used will automatically be added.
##
## `config` is a dictionary used to configure transition options:
##		`input: String`
##		`min_input_delay: float`
##		`advance_conditions: Condition[]`
##		`prereqs: Condition[]`
##		`auto_advance: bool`
##		`priority: int`
##		`switch_mode: int`
##
## Returns a reference to this builder
func transition_sequence(from: String, to: String, config: Dictionary = {}) -> RefCounted:
	var transition := _create_transition(from, to, InputTransitionSequence.new()).transition
	_configure_transition_input_button(transition, config)
	return self


## Creates a new global input button transition from one state to another.
## States used will automatically be added.
##
## `config` is a dictionary used to configure transition options:
##		`input: String`
##		`min_input_delay: float`
##		`advance_conditions: Condition[]`
##		`prereqs: Condition[]`
##		`auto_advance: bool`
##		`priority: int`
##		`switch_mode: int`
##
## Returns a reference to this builder
func transition_button_global(to: String, config: Dictionary = {}) -> RefCounted:
	var tr := _create_global_transition(to, InputTransitionButton.new())
	_configure_transition_input_sequence(tr.transition, config)
	return self

## Creates a new global input sequence transition from one state to another.
## States used will automatically be added.
##
## `config` is a dictionary used to configure transition options:
##		`input: String`
##		`min_input_delay: float`
##		`advance_conditions: Condition[]`
##		`prereqs: Condition[]`
##		`auto_advance: bool`
##		`priority: int`
##		`switch_mode: int`
##
## Returns a reference to this builder
func transition_sequence_global(to: String, config: Dictionary = {}) -> RefCounted:
	var tr := _create_global_transition(to, InputTransitionSequence.new())
	_configure_transition_input_sequence(tr.transition, config)
	return self


func _configure_transition_input(transition: FrayInputTransition, config: Dictionary) -> void:
	_configure_transition(transition, config)
	transition.auto_advance = config.get("auto_advance", false)
	transition.min_input_delay = config.get("min_input_delay", 0)


func _configure_transition_input_button(transition: FrayInputTransitionButton, config: Dictionary) -> void:
	_configure_transition_input(transition, config)
	
	if not config.has("input"):
		push_warning("No 'input' config given for input button transition")
	
	transition.input = config.get("input", "")
	transition.is_triggered_on_release = config.get("is_triggered_on_release", false)


func _configure_transition_input_sequence(transition: FrayInputTransitionSequence, config: Dictionary) -> void:
	_configure_transition_input(transition, config)
	
	if not config.has("input"):
		push_warning("No 'input' config given for input sequence transition")
	
	transition.sequence_name = config.get("input", "")
	
