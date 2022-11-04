extends Node
## A node representing a controller
##
## @desc:
##      This node is a helper node which wrapper around `FrayInput` input checks.
##      It can be used to decouple entities from the inputs they check in a way that is accesible from the node tree.
##      If an entity needs to respond to inputs from another device you only need to change the controller's `device` value.
##      It is also possible to hand the controller off to an AI by using virtual devices.

const VirtualDevice = preload("device/virtual_device.gd")

export var device: int

var _FrayInput: Node

func _ready() -> void:
    _FrayInput = get_node("/root/FrayInput")
    _FrayInput.connect("device_connection_changed", self, "_on_FrayInput_device_connection_changed")

## Returns true if an input is being pressed.
func is_pressed(input: String) -> bool:
    return is_device_connected() and _FrayInput.is_pressed(input, device)

## Returns true if any of the inputs given are being pressed
func is_any_pressed(inputs: PoolStringArray) -> bool:
    return is_device_connected() and _FrayInput.is_any_pressed(inputs, device)

## Returns true when a user starts pressing the input, 
## meaning it's true only on the frame the user pressed down the input.
func is_just_pressed(input: String) -> bool:
    return is_device_connected() and _FrayInput.is_just_pressed(input, device)

## Returns true if input was physically pressed
## meaning it is only true if the press was not trigerred virtually.
func is_just_pressed_real(input: String) -> bool:
	return is_device_connected() and _FrayInput.is_just_pressed_real(input, device)

## Returns true when the user stops pressing the input, 
## meaning it's true only on the frame that the user released the button.
func is_just_released(input: String) -> bool:
	return is_device_connected() and _FrayInput.is_just_released(input, device)

## Returns true if this controller is connected
func is_device_connected() -> bool:
    return _FrayInput.is_device_connected(device)