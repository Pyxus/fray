extends Reference

static func safe_connect(obj: Object, signal_name: String, target: Object, method: String, binds: Array = [], flags: int = 0) -> void:
	if not obj.is_connected(signal_name, target, method):
		obj.connect(signal_name, target, method, binds, flags)


static func safe_disconnect(obj: Object, signal_name: String, target: Object, method: String) -> void:
	if obj.is_connected(signal_name, target, method):
		obj.disconnect(signal_name, target, method)