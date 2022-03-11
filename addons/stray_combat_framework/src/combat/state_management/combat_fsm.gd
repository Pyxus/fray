extends Node
## docstring

signal tree_changed(from, to)
signal state_changed(from, to) 

enum ProcessMode {
	IDLE,
	PHYSICS,
	MANUAL
}

#constants

const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

export var input_detector: NodePath
export var allow_chaining: bool
export var input_buffer_max_size: int = 3
export var input_max_time_in_buffer: float = 0.1
export var active: bool
export(ProcessMode) var process_mode: int 

#public variables

var _combat_trees: Array

onready var _input_detector: InputDetector = get_node_or_null(input_detector)


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

#public methods

#private methods

#signal methods

#inner classes
