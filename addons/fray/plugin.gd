tool
extends EditorPlugin
## docstring

#inner classes

#signals

#enums


#exported variables

#public variables

var _added_types: Array
var _added_singletons: Array
var _editor_interface := get_editor_interface()
var _editor_settings := _editor_interface.get_editor_settings()

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method


func _ready() -> void:
	pass

	
func _enter_tree() -> void:
	add_autoload_singleton("FrayInputList", "res://addons/fray/src/input/autoloads/fray_input_list.gd")
	add_autoload_singleton("FrayInput", "res://addons/fray/src/input/autoloads/fray_input.gd")
	add_custom_type("SequenceAnalyzer", "Resource", Fray.Input.SequenceAnalyzer, null)
	add_custom_type("CombatGraph", "Node", Fray.StateMgmt.CombatGraph, preload("assets/icons/combat_graph.svg"))
	add_custom_type("CombatSituation", "Resource", Fray.StateMgmt.CombatSituation, null)
	add_custom_type("HitBox2D", "Area2D", Fray.Collision.Hitbox2D, preload("assets/icons/hitbox_2d.svg"))
	add_custom_type("HitStateSwitcher2D", "Node2D", Fray.Collision.HitStateSwitcher2D, preload("assets/icons/hit_state_switcher_2d.svg"))
	add_custom_type("HitState2D", "Node2D", Fray.Collision.HitState2D, preload("assets/icons/hit_state_2d.svg"))
	add_custom_type("HitAttributes", "Resource", Fray.Collision.HitboxAttributes, null)


func _exit_tree():
	for singleton in _added_singletons:
		remove_autoload_singleton(singleton)

	for type in _added_types:
		remove_custom_type(type)


func add_autoload_singleton(name: String, path: String) -> void:
	.add_autoload_singleton(name, path)
	_added_singletons.append(name)


func add_custom_type(type: String, base: String, script: Script, icon: Texture) -> void:
	.add_custom_type(type, base, script, icon)
	_added_types.append(type)
