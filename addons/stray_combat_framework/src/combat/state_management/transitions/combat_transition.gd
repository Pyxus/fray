extends "res://addons/stray_combat_framework/lib/state_machine/transition.gd"
## docstring

#signals

#enums

#constants

const InputCondition = preload("conditions/input_condition.gd")

#exported variables

var input_condition: InputCondition
var chain_conditions: Array # EvaluatedCondition[]
var min_input_delay: float

#private variables

#onready variables


func _init(t_input_condition: InputCondition = null, t_chain_conditions: Array = [], t_min_input_delay: float = 0) -> void:
    input_condition = t_input_condition
    chain_conditions = t_chain_conditions
    min_input_delay = t_min_input_delay
    
#built-in virtual _ready method

#remaining built-in virtual methods

#public methods

#private methods

#signal methods

#inner classes
