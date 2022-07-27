tool
extends EditorPlugin
## docstring

#inner classes

#signals

#enums

const FrayConfig = preload("res://addons/fray/fray_config.gd")
const ShapeColorChangeDialog = preload("editor/shape_color_change_dialog.gd")
const ShapeColorChangeDialogScn = preload("editor/shape_color_change_dialog.tscn")
const InputMapEditorScn = preload("editor/input_map/input_map_editor.tscn")

#exported variables

#public variables

var _added_types: Array
var _added_project_settings: Array
var _color_change_dialog: ShapeColorChangeDialog
var _input_map_editor = InputMapEditorScn.instance()
var _editor_interface := get_editor_interface()
var _editor_settings := _editor_interface.get_editor_settings()
var _global = load("res://addons/fray/editor/global.tres")

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	_global.base_color = _editor_settings.get_setting("interface/theme/base_color")
	
	
func _enter_tree() -> void:
	_global.base_color = _editor_settings.get_setting("interface/theme/base_color")
	_global.fray_config = FrayConfig.new()
	add_autoload_singleton("FrayInputMap", "res://addons/fray/src/input/fray_input_map.gd")
	add_autoload_singleton("FrayInput", "res://addons/fray/src/input/fray_input.gd")
	add_custom_type("SequenceAnalyzer", "Resource", FrayInputNS.SequenceAnalyzer, null)
	add_custom_type("SequenceAnalyzerTree", "Resource", FrayInputNS.SequenceAnalyzerTree, null)
	add_custom_type("CombatGraph", "Node", FrayCombatState.CombatGraph, preload("assets/icons/combat_graph.svg"))
	add_custom_type("CombatSituation", "Resource", FrayCombatState.CombatSituation, null)
	add_custom_type("HitBox2D", "Area2D", FrayHitDetection.HitBox2D, preload("assets/icons/hitbox_2d.svg"))
	add_custom_type("HitboxSwitcher2D", "Node2D", FrayHitDetection.HitboxSwitcher2D, preload("assets/icons/hitbox_switcher_2d.svg"))
	add_custom_type("HitState2D", "Node2D", FrayHitDetection.HitState2D, preload("assets/icons/hit_state_2d.svg"))
	add_custom_type("HitStateCoordinator2D", "Node2D", FrayHitDetection.HitStateCoordinator2D, preload("assets/icons/hit_state_coordinator_2d.svg"))
	add_custom_type("HitAttributes", "Resource", FrayHitDetection.HitAttributes, null)
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, _input_map_editor)
	"""
	if ProjectSettings.get("fray_settings/show_color_change_dialog"):
		_color_change_dialog = ShapeColorChangeDialogScn.instance()
		add_child(_color_change_dialog)
		_color_change_dialog.connect("option_selected", self, "_on_ShapeColorChangeDialog_option_selected")
		_color_change_dialog.popup_centered(_color_change_dialog.get_minimum_size())
	"""


func _exit_tree():
	remove_autoload_singleton("FrayInput")
	remove_autoload_singleton("FrayInputMap")
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, _input_map_editor)
	_input_map_editor.queue_free()
	for type in _added_types:
		remove_custom_type(type)


func save_external_data():
	pass


func enable_plugin() -> void:
	#add_project_setting("fray_settings/show_color_change_dialog", TYPE_BOOL, PROPERTY_HINT_NONE, "", true)
	pass
	
func disable_plugin() -> void:	
	"""
	for setting in _added_project_settings:
		ProjectSettings.clear(setting)
	ProjectSettings.save()
	"""
	pass
	

func add_custom_type(type: String, base: String, script: Script, icon: Texture) -> void:
	.add_custom_type(type, base, script, icon)
	_added_types.append(type)


func add_project_setting(name: String, type: int, hint: int, hint_string: String, initial_value) -> void:
	if ProjectSettings.has_setting(name):
		push_error("Failed to add setting. Project already contains a setting called '%s'" % name)
		return
	
	ProjectSettings.set_setting(name, initial_value)
	ProjectSettings.add_property_info({
		"name" : name,
		"type" : type,
		"hint" : hint,
		"hint_string" : hint,
	})
	ProjectSettings.set_initial_value(name, initial_value)
	ProjectSettings.save()
	_added_project_settings.append(name)
	
#private methods

func _on_ShapeColorChangeDialog_option_selected(is_accepted: bool) -> void:
	if is_accepted:
		ProjectSettings.set_setting("debug/shapes/collision/shape_color", Color("6bffffff"))
	_color_change_dialog.queue_free()
	ProjectSettings.set("fray_settings/show_color_change_dialog", false)
