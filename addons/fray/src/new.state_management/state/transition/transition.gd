extends Reference
## Represents transition from one state to another

enum SwitchMode{
    IMMEDIATE,
    AT_END,
}

## State being transitioned from.
var from: String

## State being transitioned to.
var to: String

## If 'auto_advance' is enabled then transition will occur automatically when all advance conditions are true.
## Type: Condition[]
var advance_conditions: Array

## Prevents transition from occuring unless all prerequisite conditions are true.
## Type: Condition[]
var prereqs: Array

## If true then the transition can advance automatically
var auto_advance: bool

## Transition priority
var priority: int

## Transition type
var switch_mode: int = SwitchMode.IMMEDIATE

## Returns true if this transition's 'from' and 'to' match
## the given 'from_state' and 'to_state'.
func is_transition_of(from_state: String, to_state: String) -> bool:
    return from == from_state and to == to_state