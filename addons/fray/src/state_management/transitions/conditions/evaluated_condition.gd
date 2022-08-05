extends Resource
## docstring

#signals

#enums

#constants

#preloaded scripts and scenes

export var condition: String

#NOTE: We'll just stick to string conditions for now
#export var expression: String
#export var expression_node: NodePath

func _init(ev_condition: String = "") -> void:
    condition = ev_condition
    #expression = ev_expression
    #expression_node = ev_expression_node