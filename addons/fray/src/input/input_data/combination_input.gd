extends Resource
## A virtual input composed of multiple input binds.
##
## @desc:
## 		Virtual meaning the input is treated as an invidiaul button despite multiple button presses being involved.
## 		Useful for creating diagonal buttons present in many 2D fighting games.

enum Type {
	SYNC, ## Components must all be pressed at the same time
	ASYNC, ## Components can be pressed at any time so long as they are all pressed.
	ORDERED, ## Like asynchronous but the presses must occur in order
}

var components: PoolIntArray
var type: int = Type.SYNC
var press_held_components_on_release: bool
var is_pressed: bool

var _previously_pressed: bool

func poll() -> void:
	if is_pressed:
		if not _previously_pressed:
			_previously_pressed = true
	else:
		_previously_pressed = false


func has_ids(ids: PoolIntArray) -> bool:
	if ids.empty():
		return false

	for id in components:
		if not id in ids:
			return false
	return true


func is_just_pressed() -> bool:
	return is_pressed and not _previously_pressed
	
	
func is_just_released() -> bool:
	return not is_pressed and _previously_pressed
