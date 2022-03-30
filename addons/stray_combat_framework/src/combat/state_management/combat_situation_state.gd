extends "res://addons/stray_combat_framework/lib/state_machine/state.gd"
## docstring

#signals

#enums

const CombatFSM = preload("combat_fsm.gd")

#preloaded scripts and scenes

#exported variables

var combat_fsm: CombatFSM

#private variables

#onready variables


func _init(state_combat_fsm: CombatFSM = null) -> void:
    self.combat_fsm = state_combat_fsm

#built-in virtual _ready method

#remaining built-in virtual methods

#public methods

#private methods

#signal methods

#inner classes
