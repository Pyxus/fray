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
	add_custom_type("SequenceAnalyzer", "Resource", FrayInputNS.SequenceAnalyzer, null)
	add_custom_type("SequenceAnalyzerTree", "Resource", FrayInputNS.SequenceAnalyzerTree, null)
	add_custom_type("CombatGraph", "Node", FrayStateMgmt.CombatGraph, preload("assets/icons/combat_graph.svg"))
	add_custom_type("CombatSituation", "Resource", FrayStateMgmt.CombatSituation, null)
	add_custom_type("HitBox2D", "Area2D", FrayHitDetection.HitBox2D, preload("assets/icons/hitbox_2d.svg"))
	add_custom_type("HitboxSwitcher2D", "Node2D", FrayHitDetection.HitboxSwitcher2D, preload("assets/icons/hitbox_switcher_2d.svg"))
	add_custom_type("HitState2D", "Node2D", FrayHitDetection.HitState2D, preload("assets/icons/hit_state_2d.svg"))
	add_custom_type("HitStateCoordinator2D", "Node2D", FrayHitDetection.HitStateCoordinator2D, preload("assets/icons/hit_state_coordinator_2d.svg"))
	add_custom_type("HitAttributes", "Resource", FrayHitDetection.HitAttributes, null)


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