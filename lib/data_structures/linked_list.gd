extends RefCounted

var _head: ListNode
var _itter_current: ListNode
var _count: int = 0

func add(data) -> void:
	if _head == null:
		_head = ListNode.new(data)
		_count = 1
	else:
		var next_node := _head
		while next_node._next != null:
			next_node = next_node._next
		next_node._next = ListNode.new(data)
		_count += 1

func print_list() -> void:
	if _head == null:
		print("[]")
		return

	var string := ""
	var next_node := _head
	while next_node != null:
		string += "[" + next_node.data.to_string() + "]"
		next_node = next_node.get_next()
		if next_node != null:
			string += " --> "
	print(string)


func remove_first() -> void:
	if _head != null:
		_head = _head._next
		_count -= 1


func get_head() -> ListNode:
	return _head


func get_count() -> int:
	return _count


func empty() -> bool:
	return _head == null


func clear() -> void:
	_head = null
	_count = 0


func _iter_init(arg):
	_itter_current = _head
	return _head != null


func _iter_next(arg):
	_itter_current = _itter_current._next
	return _itter_current != null


func _iter_get(arg):
	return _itter_current.data


class ListNode:
	extends RefCounted

	## Type: Variant
	var data

	## Type: ListNode
	var _next: RefCounted

	func _init(node_data) -> void:
		data = node_data

	## Returns: ListNode
	func get_next() -> RefCounted:
		return _next
