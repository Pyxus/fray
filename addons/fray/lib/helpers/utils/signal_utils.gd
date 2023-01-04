extends RefCounted

static func safe_connect(
	obj: Object, 
	signal_name: String, 
	method: Callable, binds: Array = [], flags: int = 0
	) -> int:
	if not obj.is_connected(signal_name, method):
		return obj.connect(signal_name, method.bind(binds), flags)
	return OK


static func safe_disconnect(
	obj: Object, 
	signal_name: String, 
	method: Callable) -> void:
	if obj.is_connected(signal_name, method):
		obj.disconnect(signal_name, method)
