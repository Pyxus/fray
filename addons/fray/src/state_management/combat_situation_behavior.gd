extends Reference
## Used to define behavior during a situation using the state pattern.
##
## @desc:
##      An example usage of this class would be to implement the process logic of a fighter
##      during different situations. In this logic you could control the different animations of
##      each combat state as well as other logic such as movement and jumping.

var current_state: String

func _on_Situation_state_changed(_from: String, _to: String) -> void:
    pass