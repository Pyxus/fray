extends Reference


const Transition = preload("res://addons/stray_combat_framework/src/combat/fsm_states/state_connections/transition.gd")
var StateConnection = load("res://addons/stray_combat_framework/src/combat/fsm_states/state_connection.gd")
var FighterState = load("res://addons/stray_combat_framework/src/combat/fsm_states/fighter_state.gd")

var to: Reference setget connect_to, get_connected_state
var default_transition_animation_from: String
var default_transition_animation_to: String
var transitions: Array

var _to_ref: WeakRef


func is_identical_to(state_connection: Reference) -> bool:
	assert(state_connection is StateConnection, "The passed argument needs to be of type StateConnection")
	return false


func connect_to(fighter_state: Reference) -> void:
	assert(fighter_state is FighterState, "The passed argument needs to be of type FighterState")
	_to_ref = weakref(fighter_state)
	

func get_connected_state() -> Reference:
	return _to_ref.get_ref()
