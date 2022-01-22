tool
extends Node2D
## docstring

#inner classes

#signals

#enums

const NONE = -1

const HitState2D = preload("hit_state_2d.gd")

export var switch_on_state_activated: bool = true
export var belongs_to: NodePath setget set_belongs_to
export var animation_player: NodePath setget set_animation_player

var _current_hit_state: int setget _set_current_hit_state
var _anim_player: AnimationPlayer
var _hit_states: Array = []
var _hit_state_by_id: Dictionary

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	var tree := get_tree()
	tree.connect("tree_changed", self, "_on_SceneTree_changed")
	_detect_hit_states()
	if not _hit_state_by_id.empty():
		_set_current_hit_state(0)
	_find_animation_associations()

func _get_configuration_warning() -> String:
	if _hit_states.empty():
		return "This node is expected to have HitState2D children."
	return ""


func get_current_hit_state() -> HitState2D:
	if _current_hit_state != NONE:
		return _hit_state_by_id[_current_hit_state]
	return null


func deactivate_all_hit_states_except(exception: HitState2D = null) -> void:
	for hit_state in _hit_states:
		if hit_state != exception:
			hit_state.is_active = false


func set_belongs_to(value: NodePath) -> void:
	belongs_to = value
	_detect_hit_states()

func _set_current_hit_state(value: int) -> void:
	_current_hit_state = value

	if is_inside_tree():
		if _current_hit_state != NONE:
			if _hit_state_by_id.has(_current_hit_state):
				_hit_state_by_id[_current_hit_state].is_active = true
			else:
				push_error("Current hit state value does not correspond to dictionary.")

func get_current_hit_state_obj() -> HitState2D:
	return null if not _hit_state_by_id.has(_current_hit_state) else _hit_state_by_id[_current_hit_state]

func get_animation_list() -> PoolStringArray:
	return [] if _anim_player == null else _anim_player.get_animation_list()

func set_animation_player(value: NodePath) -> void:
	animation_player = value
	_anim_player = null

	var anim_player = get_node_or_null(animation_player)
	if anim_player is AnimationPlayer:
		_anim_player = anim_player


func _find_animation_associations() -> void:
	if _anim_player != null:
		var anim_player_parent := _anim_player.get_parent()
		for anim_name in _anim_player.get_animation_list():
			var animation: Animation = _anim_player.get_animation(anim_name)
			for track in animation.get_track_count():
				var track_path := animation.track_get_path(track)
				var node_path: String
				for i in track_path.get_name_count():
					node_path += track_path.get_name(i) + "/"
				if not node_path.empty():
					var track_node := anim_player_parent.get_node(node_path)


func _detect_hit_states() -> void:
	set_animation_player(animation_player)
	
	_hit_states.clear()
	_hit_state_by_id.clear()
	
	var i: int = 0
	for child in get_children():
		if child is HitState2D:
			_hit_states.append(child)
			child.set_boxes_belong_to(get_node_or_null(belongs_to))
			if _anim_player != null:
				child.set_animation_list(_anim_player.get_animation_list())
			_hit_state_by_id[i] = child
			i += 1

			if not child.is_connected("activated", self, "_on_HitState_activated"):
				child.connect("activated", self, "_on_HitState_activated", [child])
	
	if _hit_states.empty():
		_set_current_hit_state(NONE)
	
	#property_list_changed_notify() # I guess the act of trying to set am exported nodepath changes the tree so this will get changed and prevent the property from being updated.
	#update_configuration_warning() # Seems to cause this error 'Timer was not added to SceneTree. Either add it or set autostart to true.'
	return


func _on_SceneTree_changed() -> void:
	if Engine.editor_hint:
		_detect_hit_states()
		pass

func _on_HitState_activated(hit_state: HitState2D) -> void:
	if switch_on_state_activated:
		deactivate_all_hit_states_except(hit_state)
	elif hit_state != get_current_hit_state_obj():
		hit_state.is_active = false
	pass
