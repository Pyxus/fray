extends "res://addons/stray_combat_framework/lib/state_machine/transition.gd"
## Transition that advances automatically if advance_condition is true

# Imports
const EvaluatedCondition = preload("conditions/evaluated_condition.gd")

## Allow transition to advance if true
var advance_condition: EvaluatedCondition