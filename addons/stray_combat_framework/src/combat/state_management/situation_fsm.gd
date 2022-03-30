extends "res://addons/stray_combat_framework/lib/state_machine/state_machine.gd"
## docstring

#signals

#enums

const AutoAdvanceTransition = preload("transitions/auto_advance_transition.gd")

#preloaded scripts and scenes

#exported variables

#public variables

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

#public methods

func _get_next_state(input: Object = null) -> String:
    var next_transitions := get_next_transitions(current_state)

    for transition_data in next_transitions:
        var transition := transition_data.transition as AutoAdvanceTransition
        if transition == null:
            continue
        
        if _is_condition_true(transition.advance_condition.condition):
            return transition_data.to

    return ""

#signal methods

#inner classes
