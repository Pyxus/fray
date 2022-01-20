extends Node


func _ready() -> void:
	var input_detector = $InputDetector
	input_detector.bind_action_input(2, "ui_down")
	input_detector.bind_action_input(6, "ui_right")
	input_detector.bind_action_input(8, "ui_up")
	input_detector.bind_action_input(4, "ui_left")
	input_detector.register_combination(1, [4, 2])
	input_detector.register_combination(3, [2, 6])
	input_detector.register_combination(9, [8, 6])
	input_detector.register_combination(7, [8, 4])


func _process(delta: float) -> void:
	var input_detector = $InputDetector
	var buffer := ""
	for input in input_detector._input_buffer:
		buffer += "%d," % input.id

	$Label.text = buffer