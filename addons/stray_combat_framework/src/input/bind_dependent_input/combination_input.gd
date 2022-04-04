extends Resource
## docstring

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

var components: PoolIntArray
var is_ordered: bool
var is_simeultaneous: bool
var press_held_components_on_release: bool
var is_pressed: bool

var _previously_pressed: bool

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

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

func is_just_released() -> bool:
	return not is_pressed and _previously_pressed


func is_just_pressed() -> bool:
	return is_pressed and not _previously_pressed
#private methods

#signal methods

#inner classes
