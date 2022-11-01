extends Reference
## Simple wrapper around `AStar` class.
##
## @desc:
##		Used by `StateCompound` class

## Type: Dictionary<String, int>
## Hint: <state name, point id>
var _point_id_by_state: Dictionary

## Type: Dictionary<int, String>
## Hint: <point id, state name>
var _state_by_point_id: Dictionary

var _astar: CustomAStar
var _astar_point_id := 0
var _travel_path: PoolStringArray
var _travel_index: int


func _init(func_get_transition: FuncRef) -> void:
	_astar = CustomAStar.new(func_get_transition, funcref(self, "_get_state_from_id"))

func add_point(state_name: String) -> void:
	_point_id_by_state[state_name] = _astar_point_id
	_state_by_point_id[_astar_point_id] = state_name
	_astar.add_point(_astar_point_id, Vector3.ZERO)
	_astar_point_id += 1


func remove_point(state_name: String) -> void:
	var point_id: int = _point_id_by_state[state_name]
	_astar.remove_point(point_id)
	_point_id_by_state.erase(state_name)
	_state_by_point_id.erase(point_id)


func connect_points(from: String, to: String, bidirectional: bool) -> void:
	_astar.connect_points(_point_id_by_state[from], _point_id_by_state[to], bidirectional)


func disconnect_points(from: String, to: String, bidirectional: bool) -> void:
	_astar.disconnect_points(_point_id_by_state[from], _point_id_by_state[to], bidirectional)


func compute_travel_path(from: String, to: String) -> void:
	var id_path := _astar.get_id_path(_point_id_by_state[from], _point_id_by_state[to])
	var state_path := PoolStringArray()

	for id in id_path:
		state_path.append(_state_by_point_id[id])
	
	_travel_index = 0
	_travel_path = state_path


func get_computed_travel_path() -> PoolStringArray:
	return _travel_path

	
func clear_travel_path() -> void:
	_travel_path = PoolStringArray()

	
func has_next_travel_state() -> bool:
	return _travel_index < _travel_path.size()


func get_next_travel_state() -> String:
	if not has_next_travel_state():
		return ""
	var next_state := _travel_path[_travel_index]
	_travel_index += 1
	return next_state


func _get_state_from_id(id: int) -> String:
	return _state_by_point_id[id]


class CustomAStar:
	extends AStar

	## Type: (String, String) -> int
	var _func_get_transition: FuncRef

	## Type: (int) -> String
	var _func_get_state_from_id: FuncRef

	func _init(func_get_transition: FuncRef, func_get_state_from_id: FuncRef) -> void:
		_func_get_transition = func_get_transition
		_func_get_state_from_id = func_get_state_from_id

	func _compute_cost(from_id: int, to_id: int) -> float:
		var transition = _func_get_transition.call_func(_func_get_state_from_id.call_func(from_id), _func_get_state_from_id.call_func(to_id))
		return transition.priority