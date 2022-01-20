extends Node
## docstring

class CombatState extends Reference:
	var nearest_idle_state: IdleState setget set_nearest_idle_state
	var extended_state: CombatState setget extend
	var animation: String
	
	var _action_states: Array
	var _extended_combat_states
	
	func extend(value: CombatState):
		if value == self:
			push_warning("CombatState can't extend self")
			return
		extended_state = value
	
	func chain_action(action_state: ActionState):
		if _action_states.has(action_state):
			push_warning("Action is already chained")
			return

		_action_states.append(action_state)
		update_chain_nearest_idle()
		
	func unchain_action(action_state: ActionState):
		if _action_states.has(action_state):
			_action_states.erase(action_state)
		
	func set_nearest_idle_state(value: IdleState):
		nearest_idle_state = value
		update_chain_nearest_idle()
	
	func update_chain_nearest_idle():
		for action_state in _action_states:
			if action_state.nearest_idle_state != nearest_idle_state:
				action_state.nearest_idle_state = nearest_idle_state

class IdleState extends CombatState:
	var transition_animation: String
	var end_animation: String
	var active_conditions: Array
	var is_one_shot: bool = false

	func chain_action(action_state: ActionState):
		action_state.nearest_idle_state = self
		.chain_action(action_state)

class RootIdleState extends IdleState:
	func extend(value: CombatState):
		push_warning("RootState is unable to extend another state")

class ActionState extends CombatState:
	var input_sequence: String
	var chain_conditions: Array
	var cancel_conditions: Array

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

#public variables

var _root_by_situation: Dictionary
var _current_situation: String

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

func create_situation(situation: String) -> RootIdleState:
	var root := RootIdleState.new()
	if _root_by_situation.has(situation):
		push_warning("Sitatuon '%s' already exists" % situation)
		return null
	_root_by_situation[situation] = root
	return root 

func remove_situation(situation: String) -> void:
	if _root_by_situation.has(situation):
		_root_by_situation.erase(situation)

func get_situation_root(situation: String) -> RootIdleState:
	if _root_by_situation.has(situation):
		return _root_by_situation[situation]
	return null

func set_current_situation(situation: String) -> void:
	if not _root_by_situation.has(situation):
		push_error("Failed to set situation. Situation '%s' does not exist." % situation)
		return
	_current_situation = situation

#private methods

#signal methods
