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
	add_custom_type("InputDetector", "Node", FrayInput.InputDetector, preload("assets/icons/input_detector.svg"))
	add_custom_type("InputData", "Resource", FrayInput.InputData, null)
	add_custom_type("SequenceAnalyzer", "Resource", FrayInput.SequenceAnalyzer, null)
	add_custom_type("SequenceAnalyzerTree", "Resource", FrayInput.SequenceAnalyzerTree, null)
	add_custom_type("ActionGraph", "Node", FrayStateManagement.ActionGraph, preload("assets/icons/action_graph.svg"))
	add_custom_type("ActionFSM", "Resource", FrayStateManagement.ActionFSM, null)
	add_custom_type("SituationFSM", "Resource", FrayStateManagement.SituationFSM, null)
	add_custom_type("HitBox2D", "Area2D", FrayHitDetection.HitBox2D, preload("assets/icons/hitbox_2d.svg"))
	add_custom_type("HitboxSwitcher2D", "Node2D", FrayHitDetection.HitboxSwitcher2D, preload("assets/icons/hitbox_switcher_2d.svg"))
	add_custom_type("HitState2D", "Node2D", FrayHitDetection.HitState2D, preload("assets/icons/hit_state_2d.svg"))
	add_custom_type("HitStateCoordinator2D", "Node2D", FrayHitDetection.HitStateCoordinator2D, preload("assets/icons/hit_state_coordinator_2d.svg"))
	add_custom_type("HitAttributes", "Resource", FrayHitDetection.HitAttributes, null)

	if ProjectSettings.get_setting("debug/shapes/collision/shape_color") != Color("6bffffff"):
		ProjectSettings.set_setting("debug/shapes/collision/shape_color", Color("6bffffff"))
		push_warning("Just a heads up. This plugin sets your collision shape color to white for cosmetic reasons. You'll notice the change on reset. Eventually i'll add a pop up but for now you'll have to manually disable the code that causes this change if you don't like it")


func _exit_tree() -> void:
	if ProjectSettings.get_setting("debug/shapes/collision/shape_color") != Color("6bffffff"):
		ProjectSettings.set_setting("debug/shapes/collision/shape_color", Color( 0, 0.6, 0.7, 0.42 ))
	for type in _added_types:
		remove_custom_type(type)


func add_custom_type(type: String, base: String, script: Script, icon: Texture) -> void:
	.add_custom_type(type, base, script, icon)
	_added_types.append(type)

#private methods

#signal methods
