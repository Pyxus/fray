@icon("res://addons/fray/assets/icons/controller.svg")
class_name FrayController
extends Node
## A node representing a controller
##
## @desc:
##      This node is a helper node which wrapper around `FrayInput` input checks.
##      It can be used to decouple entities from the inputs they check in a way that is accesible from the node tree.
##      If an entity needs to respond to inputs from another device you only need to change the controller's `device` value.
##      It is also possible to hand the controller off to an AI by using virtual devices.


@export var device: int
@export var disabled: bool

@onready var _fray_input: Node = get_node("/root/FrayInput")

func _ready() -> void:
	if _fray_input == null:
		push_error("Failed to access FrayInput singleton. Fray plugin may not be enabled.")
		return

## Returns true if this controller is connected
func is_device_connected() -> bool:
	return _fray_input.is_device_connected(device)

## Returns true if an input is being pressed.
func is_pressed(input: String) -> bool:
	return not disabled and is_device_connected() and _fray_input.is_pressed(input, device)

## Returns true if any of the inputs given are being pressed
func is_any_pressed(inputs: PackedStringArray) -> bool:
	return not disabled and is_device_connected() and _fray_input.is_any_pressed(inputs, device)

## Returns true when a user starts pressing the input, 
## meaning it's true only on the frame the user pressed down the input.
func is_just_pressed(input: String) -> bool:
	return not disabled and is_device_connected() and _fray_input.is_just_pressed(input, device)

## Returns true if input was physically pressed
## meaning it is only true if the press was not trigerred virtually.
func is_just_pressed_real(input: String) -> bool:
	return not disabled and is_device_connected() and _fray_input.is_just_pressed_real(input, device)

## Returns true when the user stops pressing the input, 
## meaning it's true only on the frame that the user released the button.
func is_just_released(input: String) -> bool:
	return not disabled and is_device_connected() and _fray_input.is_just_released(input, device)

## Returns a value between 0 and 1 representing the intensity of an input.
## If the input has no range of strngth a discrete value of 0 or 1 will be returned.
func get_strength(input: String) -> float:
	return _fray_input.get_strength(input, device) if is_device_connected() and not disabled else 0.0

## Get axis input by specifiying two input ids, one negative and one positive.
func get_axis(negative_input: String, positive_input: String) -> float:
	return _fray_input.get_axis(negative_input, positive_input, device) if is_device_connected() and not disabled else 0.0
