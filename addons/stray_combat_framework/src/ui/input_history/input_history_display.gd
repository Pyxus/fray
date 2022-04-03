extends PanelContainer

"""
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const DetectedVirtualInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_virtual_input.gd")
const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")
const InputView = preload ("input_view.gd")
const InputViewScn = preload("input_view.tscn")

export var input_id_visible: bool setget set_input_id_visible

var input_detector: InputDetector setget set_input_detector

var _texture_by_id: Dictionary
var _last_input_time_stamp: int
var _tree: SceneTree

onready var _input_view_container: Control = get_node("InputViewContainer")


func _ready() -> void:
	_tree = get_tree()


func _process(delta: float) -> void:
	for node in _input_view_container.get_children():
		if node is Control:
			var viewport_rect := _tree.root.get_visible_rect()
			if not viewport_rect.intersects(node.get_global_rect(), true):
				node.queue_free()


func set_input_detector(input_detector: InputDetector) -> void:
	if input_detector != null and input_detector.is_connected("input_detected", self, "_on_InputDetector_input_detected"):
		input_detector.disconnect("input_detected", self, "_on_InputDetector_input_detected")
	input_detector.connect("input_detected", self, "_on_InputDetector_input_detected")


func set_input_texture(input_id: int, texture: Texture) -> void:
	_texture_by_id[input_id] = texture


func set_input_id_visible(value: bool) -> void:
	input_id_visible = value

	for node in _input_view_container.get_children():
		if node is InputView:
			node.id_label_visible = input_id_visible


func add_input(detected_input: DetectedInput) -> void:
	if abs(_last_input_time_stamp - detected_input.time_stamp) / 1000.0 >= .5:
		var spacer := Control.new()
		_input_view_container.add_child(spacer)
		_input_view_container.move_child(spacer, 0)
		spacer.rect_min_size.y = 30

	var input_view: InputView = InputViewScn.instance()
	_input_view_container.add_child(input_view)
	_input_view_container.move_child(input_view, 0)

	input_view.input_id = detected_input.input_id
	input_view.time_stamp = detected_input.time_stamp
	input_view.id_label_visible = input_id_visible

	_last_input_time_stamp = detected_input.time_stamp

	if _texture_by_id.has(detected_input.input_id):
		input_view.icon_texture = _texture_by_id[detected_input.input_id]


func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	if detected_input is DetectedVirtualInput:
		if detected_input.is_pressed:
			add_input(detected_input)
"""