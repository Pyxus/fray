extends Resource
## docstring

#signals

#enums

#constants

#preloaded scripts and scenes

export var condition: String
export var expression: String
export var expression_node: NodePath

#public variables

#private variables

#onready variables


func _init(ev_condition: String = "", ev_expression: String = "", ev_expression_node: NodePath = "") -> void:
    condition = ev_condition
    expression = ev_expression
    expression_node = ev_expression_node

#built-in virtual _ready method

#remaining built-in virtual methods

#public methods

#private methods

#signal methods

#inner classes
