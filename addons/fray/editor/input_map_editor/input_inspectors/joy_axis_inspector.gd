tool
extends "input_inspector.gd"

onready var _axis_selector: OptionButton = $"ScrollContainer/PropertyContainer/AxisProperty/AxisSelector"
onready var _positive_check_box: CheckBox = $"ScrollContainer/PropertyContainer/CheckPositiveProperty/PositiveCheckBox"
onready var _deadzone_spin_box: SpinBox = $"ScrollContainer/PropertyContainer/DeadzoneProperty/DeadzoneSpinBox"


func _ready() -> void:
	pass


func _setup() -> void:
	_axis_selector.get_popup().connect("id_pressed", self, "_on_AxisSelector_Popup_id_pressed")
	
	for axis in range(JOY_AXIS_0, JOY_AXIS_MAX):
		_axis_selector.add_item("Axis %d: " % axis + Input.get_joy_axis_string(axis), axis)
	
	for i in _axis_selector.get_item_count():
		var item_id := _axis_selector.get_item_id(i)
		if item_id == _input_data.axis:
			_axis_selector.select(i)
			break

	_positive_check_box.pressed = _input_data.check_positive
	_deadzone_spin_box.value = _input_data.deadzone


func _on_AxisSelector_Popup_id_pressed(id: int) -> void:
	_input_data.axis = id
	emit_signal("save_requested")


func _on_PositiveCheckBox_pressed() -> void:
	_input_data.check_positive = _positive_check_box.pressed
	emit_signal("save_requested")


func _on_DeadzoneSpinBox_value_changed(value_changed: float) -> void:
	_input_data.deadzone = value_changed
	emit_signal("save_request")
