extends Reference
## Class used to represent transition config

enum SwitchMode{
    IMMEDIATE,
    AT_END,
}

## If 'auto_advance' is enabled then transition will occur automatically
## when all advance conditions are true.
## Type: Condition[]
var advance_conditions: Array

## Prevents transition from occuring unless all prerequisite conditions are true.
## Type: Condition[]
var prerequisites: Array

## If true then the transition can advance automatically
var auto_advance: bool

## Transition priority
var priority: int

## Transition type
var switch_mode: int = SwitchMode.IMMEDIATE

## If true then the transition can advance.
## This means `auto_advance` is enabled and all advance conditions are met
func can_advance() -> bool:
    if not auto_advance:
        return false

    for condition in advance_conditions:
        if not condition.is_satisfied():
            return false

    return true

## If true all prerequsites are satisfied.
func is_prereqs_satisfied() -> bool:
    for condition in prerequisites:
        if not condition.is_satisfied():
            return false
    return true