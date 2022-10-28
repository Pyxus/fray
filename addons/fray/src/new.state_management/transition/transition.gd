extends Reference
## Represents transition from one state to another

const TransitionConfig = preload("transition_config.gd")

## State being transitioned from.
var from: String

## State being transitioned to.
var to: String

## Transition config.
var config := TransitionConfig.new()

## If true then the transition can advance.
## This means `auto_advance` is enabled and all advance conditions are met
func can_advance() -> bool:
    if not config.auto_advance:
        return false

    for condition in config.advance_conditions:
        if not condition.is_satisfied():
            return false

    return true

## Returns true if this transition's 'from' and 'to' match
## the given 'from_state' and 'to_state'.
func is_transition_of(from_state: String, to_state: String) -> bool:
    return from == from_state and to == to_state

## If true then the transition can occur.
## By default this means all prerequsites are satisfied.
func can_transition() -> bool:
    return _can_transition()

## Virtual method used to define `can_transition` method
func _can_transition() -> bool:
    return config.is_prereqs_satisfied()