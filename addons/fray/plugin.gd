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
	add_custom_type("InputDetector", "Node", Fray.InputDetector, preload("assets/icons/input_detector.svg"))
	add_custom_type("ActionGraph", "Node", Fray.ActionGraph, preload("assets/icons/action_graph.svg"))
	add_custom_type("HitBox2D", "Area2D", Fray.HitBox2D, preload("assets/icons/hitbox_2d.svg"))
	add_custom_type("HitboxSwitcher2D", "Node2D", Fray.HitboxSwitcher2D, preload("assets/icons/hitbox_switcher_2d.svg"))
	add_custom_type("HitState2D", "Node2D", Fray.HitState2D, preload("assets/icons/hit_state_2d.svg"))
	add_custom_type("HitStateCoordinator2D", "Node2D", Fray.HitStateCoordinator2D, preload("assets/icons/hit_state_coordinator_2d.svg"))
	add_custom_type("HitAttributes", "Resource", Fray.HitAttributes, null)
	add_custom_type("InputData", "Resource", Fray.InputData, null)
	add_custom_type("SequenceAnalyzer", "Resource", Fray.SequenceAnalyzer, null)
	add_custom_type("SequenceAnalyzerTree", "Resource", Fray.SequenceAnalyzerTree, null)
	add_custom_type("ActionFSM", "Resource", Fray.ActionFSM, null)
	add_custom_type("SituationFSM", "Resource", Fray.SituationFSM, null)

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
