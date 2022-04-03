extends Node
## docstring

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

var combined_ids: PoolIntArray
var is_simeultaneous: bool
var press_held_components_on_release: bool

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

func has_ids(ids: PoolIntArray) -> bool:
    if ids.empty():
        return false

    for id in combined_ids:
        if not id in ids:
            return false
    return true

#private methods

#signal methods

#inner classes
