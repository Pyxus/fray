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
	add_custom_type("CombatFSM", "Node", StrayCF.CombatFSM, preload("assets/icons/combat_fsm.svg"))
	#add_custom_type("CharacterBody2D", "RigidBody2D", StrayCF.CharacterBody2D, null)
	add_custom_type("FighterBody2D", "RigidBody2D", StrayCF.FighterBody2D, preload("assets/icons/fighter_body_2d.svg"))
	add_custom_type("PushBox2D", "RigidBody2D", StrayCF.PushBox2D, preload("assets/icons/push_box_2d.svg"))
	#add_custom_type("DetectionBox2D", "Area2D", StrayCF.DetectionBox2D, preload("assets/icons/fighter_body_2d.svg"))
	add_custom_type("HitBox2D", "Area2D", StrayCF.HitBox2D, preload("assets/icons/hit_box_2d.svg"))
	add_custom_type("HurtBox2D", "Area2D", StrayCF.HurtBox2D, preload("assets/icons/hurt_box_2d.svg"))
	add_custom_type("BoxSwitcher2D", "Node2D", StrayCF.BoxSwitcher2D, preload("assets/icons/box_switcher_2d.svg"))
	add_custom_type("HitState2D", "Node2D", StrayCF.HitState2D, preload("assets/icons/hit_state_2d.svg"))
	add_custom_type("HitStateController2D", "Node2D", StrayCF.HitStateController2D, preload("assets/icons/hit_state_controller_2d.svg"))
	#add_autoload_singleton("StrayInput", "res://addons/stray_combat_framework/input/stray_input.gd")


func _exit_tree() -> void:
	#remove_autoload_singleton("StrayInput")
	for type in _added_types:
		remove_custom_type(type)


func add_custom_type(type: String, base: String, script: Script, icon: Texture) -> void:
	.add_custom_type(type, base, script, icon)
	_added_types.append(type)

#private methods

#signal methods
