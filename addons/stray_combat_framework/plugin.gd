tool
extends EditorPlugin
## docstring

#inner classes

#signals

#enums

#constants

#exported variables

#public variables

var _added_types: Array

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

func _enter_tree() -> void:
	add_custom_type("InputDetector", "Node", StrayCF.InputDetector, preload("assets/icons/input_detector.svg"))
	add_custom_type("CombatFSM", "Node", StrayCF.CombatFSM, preload("assets/icons/combat_fsm.svg"))
	add_custom_type("CharacterBody2D", "RigidBody2D", StrayCF.CharacterBody2D, null)
	add_custom_type("FighterBody2D", "RigidBody2D", StrayCF.RigidFighterBody2D, preload("assets/icons/fighter_body_2d.svg"))
	add_custom_type("PushBox2D", "RigidBody2D", StrayCF.RigidPushBox2D, preload("assets/icons/push_box_2d.svg"))
	add_custom_type("HitBox2D", "Area2D", StrayCF.HitBox2D, preload("assets/icons/hit_box_2d.svg"))
	add_custom_type("BoxSwitcher2D", "Node2D", StrayCF.BoxSwitcher2D, preload("assets/icons/box_switcher_2d.svg"))
	add_custom_type("HitState2D", "Node2D", StrayCF.HitState2D, preload("assets/icons/hit_state_2d.svg"))
	add_custom_type("HitStateController2D", "Node2D", StrayCF.HitStateController2D, preload("assets/icons/hit_state_controller_2d.svg"))

	if ProjectSettings.get_setting("debug/shapes/collision/shape_color") != Color("6bffffff"):
		ProjectSettings.set_setting("debug/shapes/collision/shape_color", Color("6bffffff"))
		push_warning("Just a heads up. This plugin sets your collision shape color to white for cosmetic reasons. You'll notice the change on reset. Eventually i'll add a pop up but for now you'll have to manually disable the code that causes this change if you don't like it")


func _exit_tree() -> void:
	ProjectSettings.set_setting("debug/shapes/collision/shape_color", Color( 0, 0.6, 0.7, 0.42 ))
	for type in _added_types:
		remove_custom_type(type)


func add_custom_type(type: String, base: String, script: Script, icon: Texture) -> void:
	.add_custom_type(type, base, script, icon)
	_added_types.append(type)

#private methods

#signal methods
