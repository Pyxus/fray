extends "res://addons/stray_combat_framework/lib/state_machine/state.gd"
## docstring

#signals

#enums

const ActionFSM = preload("action_fsm.gd")

#preloaded scripts and scenes

#exported variables

var action_fsm: ActionFSM

#private variables

#onready variables


func _init(state_action_fsm: ActionFSM = null) -> void:
    action_fsm = state_action_fsm

#built-in virtual _ready method

#remaining built-in virtual methods

#public methods

#private methods

#signal methods

#inner classes
