extends RefCounted

## Connects signal only if not already connected.
static func safe_connect( 
	sig: Signal, 
	method: Callable, binds: Array = [], flags: int = 0
	) -> int:
	if not sig.is_connected(method):
		for bind in binds:
			method = method.bind(bind)
		return sig.connect(method, flags)
	return OK

## Disconnects signal only if already connected.
static func safe_disconnect(
	sig: Signal,
	method: Callable) -> void:
	if sig.is_connected(method):
		sig.disconnect(method)
