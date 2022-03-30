extends "res://addons/stray_combat_framework/lib/state_machine/transition.gd"
## docstring

#signals

#enums

#constants

const InputCondition = preload("conditions/input_condition.gd")

#exported variables

var input_condition: InputCondition
var chain_conditions: Array # CombatCondition[]
var min_input_delay: float

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

#public methods

#private methods

#signal methods

#inner classes
