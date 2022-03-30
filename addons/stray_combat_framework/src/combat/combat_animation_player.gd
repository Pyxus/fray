extends AnimationPlayer
## docstring

#signals

#enums

#constants

const CombatTree = preload("combat_tree.gd")
const CombatAnimation = preload("state_management/combat_animation.gd")

export var combat_tree: NodePath

#public variables

#private variables

onready var _combat_tree: CombatTree = get_node_or_null(combat_tree)


#optional built-in virtual _init method

func _ready() -> void:
    if _combat_tree != null:
        _combat_tree.connect("situation_changed", self, "_on_CombatTree_situation_changed")
        _combat_tree.connect("combat_state_changed", self, "_on_CombatTree_combat_state_changed")

#remaining built-in virtual methods

func associate_combat_state_with_animation() -> void:
    pass

#private methods

func _on_CombatTree_situation_changed(from: String, to: String) -> void:
    pass


func _on_CombatTree_combat_state_changed(from: String, to: String) -> void:
    pass

#inner classes
