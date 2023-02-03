extends RefCounted
## Simple wrapper around [AStar2D] class that stores points as string names.

# Type: Dictionary<String, int>
# Hint: <state name, point id>
var _point_id_by_node: Dictionary

# Type: Dictionary<int, String>
# Hint: <point id, state name>
var _node_by_point_id: Dictionary

var _astar: _CustomAStar
var _astar_point_id := 0
var _travel_path: PackedStringArray
var _travel_index: int

## `func_get_transition_cost: (String, String) -> float`
func _init(func_get_transition_cost: Callable) -> void:
	_astar = _CustomAStar.new(func_get_transition_cost, _get_node_from_id)


func add_point(state_name: StringName) -> void:
	_point_id_by_node[state_name] = _astar_point_id
	_node_by_point_id[_astar_point_id] = state_name
	_astar.add_point(_astar_point_id, Vector2.ZERO)
	_astar_point_id += 1


func remove_point(state_name: StringName) -> void:
	var point_id: int = _point_id_by_node[state_name]
	_astar.remove_point(point_id)
	_point_id_by_node.erase(state_name)
	_node_by_point_id.erase(point_id)


func rename_point(old_name: StringName, new_name: StringName) -> void:
	if _point_id_by_node.has(old_name) and not _point_id_by_node.has(new_name):
		var id: int = _point_id_by_node[old_name]
		
		_point_id_by_node.erase(old_name)
		_node_by_point_id.erase(id)

		_point_id_by_node[new_name] = id
		_node_by_point_id[id] = new_name


func connect_points(from: StringName, to: StringName, bidirectional: bool) -> void:
	_astar.connect_points(_point_id_by_node[from], _point_id_by_node[to], bidirectional)


func disconnect_points(from: StringName, to: StringName, bidirectional: bool) -> void:
	_astar.disconnect_points(_point_id_by_node[from], _point_id_by_node[to], bidirectional)


func compute_travel_path(from: StringName, to: StringName) -> PackedStringArray:
	var id_path := _astar.get_id_path(_point_id_by_node[from], _point_id_by_node[to])
	var path := PackedStringArray()

	for id in id_path:
		path.append(_node_by_point_id[id])
	
	_travel_index = 0
	_travel_path = path
	return path


func get_computed_travel_path() -> PackedStringArray:
	return _travel_path

	
func clear_travel_path() -> void:
	_travel_path = PackedStringArray()

	
func has_next_travel_node() -> bool:
	return _travel_index < _travel_path.size()


func get_next_travel_node() -> StringName:
	if not has_next_travel_node():
		return ""
	var next_state := _travel_path[_travel_index]
	_travel_index += 1
	return next_state


func _get_node_from_id(id: int) -> StringName:
	return _node_by_point_id[id]


class _CustomAStar:
	extends AStar2D

	## Type: (String, String) -> int
	var _func_get_transition_cost: Callable

	## Type: (int) -> String
	var _func_get_node_from_id: Callable

	func _init(func_get_transition_cost: Callable, func_get_node_from_id: Callable) -> void:
		_func_get_transition_cost = func_get_transition_cost
		_func_get_node_from_id = func_get_node_from_id

	func _compute_cost(from_id: int, to_id: int) -> float:
		var from: StringName = _func_get_node_from_id.call(from_id)
		var to: StringName = _func_get_node_from_id.call(to_id)
		return _func_get_transition_cost.call(from, to)
