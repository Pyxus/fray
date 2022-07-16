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

var components: PoolStringArray
var type: int = Type.SYNC
var press_held_components_on_release: bool
var is_pressed: bool


func has_components(names: PoolStringArray) -> bool:
	if names.empty():
		return false

	for name in names:
		if not name in names:
			return false
	return true
