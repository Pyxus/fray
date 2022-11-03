extends "state_machine_global_builder.gd"

const InputTransition = preload("../graph_node/transition/input_transition.gd")
const InputTransitionButton = preload("../graph_node/transition/input_transition_button.gd")
const InputTransitionSequence = preload("../graph_node/transition/input_transition_sequence.gd")

## Creates a new input button transition from one state to another.
## States used will automatically be added.
##
## `config` is a dictionary used to configure transition options:
##		`min_input_delay: float`
##		`advance_conditions: Condition[]`
##		`prereqs: Condition[]`
##		`auto_advance: bool`
##		`priority: int`
##		`switch_mode: int`
##
## Returns a reference to this builder
func transition_button(from: String, to: String, input: String, config: Dictionary = {}) -> Reference:
	var transition := _create_transition(from, to, InputTransitionButton.new()).transition
	_configure_transition_input_button(transition, input, config)
	return self

## Creates a new inupt sequence transition from one state to another.
## States used will automatically be added.
##
## `config` is a dictionary used to configure transition options:
##		`min_input_delay: float`
##		`is_triggered_on_release: bool`
##		`advance_conditions: Condition[]`
##		`prereqs: Condition[]`
##		`auto_advance: bool`
##		`priority: int`
##		`switch_mode: int`
##
## Returns a reference to this builder
func transition_sequence(from: String, to: String, input: String, config: Dictionary = {}) -> Reference:
	var transition := _create_transition(from, to, InputTransitionSequence.new()).transition
	_configure_transition_input_button(transition, input, config)
	return self


## Creates a new global input button transition from one state to another.
## States used will automatically be added.
##
## Returns a reference to this builder
func transition_button_global(to: String, input: String, config: Dictionary = {}) -> Reference:
	var tr := _create_global_transition(to, InputTransitionButton.new())
	_configure_transition_input_sequence(tr.transition, input, config)
	return self

## Creates a new global input sequence transition from one state to another.
## States used will automatically be added.
##
## Returns a reference to this builder
func transition_sequence_global(to: String, input: String, config: Dictionary = {}) -> Reference:
	var tr := _create_global_transition(to, InputTransitionSequence.new())
	_configure_transition_input_sequence(tr.transition, input, config)
	return self


func _configure_transition_input(transition: InputTransition, config: Dictionary) -> void:
	_configure_transition(transition, config)
	transition.min_input_delay = config.get("min_input_delay", 0)


func _configure_transition_input_button(transition: InputTransitionButton, input: String, config: Dictionary) -> void:
	_configure_transition_input(transition, config)
	transition.input = input
	transition.is_triggered_on_release = config.get("is_triggered_on_release", false)


func _configure_transition_input_sequence(transition: InputTransitionSequence, input: String, config: Dictionary) -> void:
	_configure_transition_input(transition, config)
	transition.sequence_name = input
	