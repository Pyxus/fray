@tool
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
	add_autoload_singleton("FrayInputMap", "res://addons/fray/src/input/autoloads/fray_input_map.gd")
	add_autoload_singleton("FrayInput", "res://addons/fray/src/input/autoloads/fray_input.gd")
	add_custom_type("Controller", "Node", FrayController, null)
	add_custom_type("StateMachine", "Node", FrayStateMachine, null)
	add_custom_type("CombatStateMachine", "Node", FrayCombatStateMachine, null)
	add_custom_type("Hitbox2D", "Area2D", FrayHitbox2D, null)
	add_custom_type("HitStateManager2D", "Node2D", FrayHitStateManager2D, null)
	add_custom_type("HitState2D", "Node2D", FrayHitState2D, null)
	#add_custom_type("Hitbox3D", "Area", Fray.Collision.Hitbox3D, preload("assets/icons/hitbox_3d.svg"))
	#add_custom_type("HitStateManager3D", "Spatial", Fray.Collision.HitStateManager3D, preload("assets/icons/hit_state_manager_3d.svg"))
	#add_custom_type("HitState3D", "Spatial", Fray.Collision.HitState3D, preload("assets/icons/hit_state_3d.svg"))
	add_custom_type("HitAttributes", "Resource", FrayHitboxAttributes, null)


func _exit_tree():
	for singleton in _added_singletons:
		remove_autoload_singleton(singleton)

	for type in _added_types:
		remove_custom_type(type)


func add_autoload_singleton(name: String, path: String) -> void:
	super(name, path)
	_added_singletons.append(name)


func add_custom_type(type: String, base: String, script: Script, icon: Texture2D) -> void:
	super(type, base, script, icon)
	_added_types.append(type)
