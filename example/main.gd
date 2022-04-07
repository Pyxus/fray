extends Node

const SequenceData = Fray.SequenceData

enum Btn {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	UP_LEFT,
	UP_RIGHT,
	DOWN_LEFT,
	DOWN_RIGHT,
	KICK,
	PUNCH,
	SLASH,
	HEAVY_SLASH,
}


onready var input_detector = get_node("NewInputDetector")

func _ready() -> void:

	"""
	var input_history_display = $UI/InputHistoryDisplay
	#input_history_display.input_detector = $Player.input_detector
	input_history_display.input_id_visible = false
	input_history_display.set_input_texture(Btn.UP, preload("res://addons/fray/assets/sprites/input_buttons/Up.png"))
	input_history_display.set_input_texture(Btn.DOWN, preload("res://addons/fray/assets/sprites/input_buttons/Down.png"))
	input_history_display.set_input_texture(Btn.LEFT, preload("res://addons/fray/assets/sprites/input_buttons/Left.png"))
	input_history_display.set_input_texture(Btn.RIGHT, preload("res://addons/fray/assets/sprites/input_buttons/Right.png"))
	input_history_display.set_input_texture(Btn.UP_LEFT, preload("res://addons/fray/assets/sprites/input_buttons/Up_Left.png"))
	input_history_display.set_input_texture(Btn.UP_RIGHT, preload("res://addons/fray/assets/sprites/input_buttons/Up_Right.png"))
	input_history_display.set_input_texture(Btn.DOWN_RIGHT, preload("res://addons/fray/assets/sprites/input_buttons/Down_Right.png"))
	input_history_display.set_input_texture(Btn.DOWN_LEFT, preload("res://addons/fray/assets/sprites/input_buttons/Down_Left.png"))

	input_history_display.set_input_texture(Btn.KICK, preload("res://addons/fray/assets/sprites/input_buttons/PS4_Cross.png"))
	input_history_display.set_input_texture(Btn.PUNCH, preload("res://addons/fray/assets/sprites/input_buttons/PS4_Square.png"))
	input_history_display.set_input_texture(Btn.SLASH, preload("res://addons/fray/assets/sprites/input_buttons/PS4_Triangle.png"))
	input_history_display.set_input_texture(Btn.HEAVY_SLASH, preload("res://addons/fray/assets/sprites/input_buttons/PS4_Circle.png"))
	"""
	pass


func _process(delta):
	pass
