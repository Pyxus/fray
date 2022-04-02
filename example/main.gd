extends Node


enum VInput {
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

const RS = preload("res://addons/stray_combat_framework/src/new_input/sequence/requirement_sequence.gd")

onready var input_detector = get_node("NewInputDetector")

func _ready() -> void:
	input_detector.bind_action_input(VInput.UP, "up")
	input_detector.bind_action_input(VInput.DOWN, "down")
	input_detector.bind_action_input(VInput.LEFT, "left")
	input_detector.bind_action_input(VInput.RIGHT, "right")
	input_detector.bind_action_input(VInput.KICK, "kick")
	input_detector.bind_action_input(VInput.PUNCH, "punch")
	input_detector.bind_action_input(VInput.SLASH, "slash")
	input_detector.bind_action_input(VInput.HEAVY_SLASH, "heavy_slash")

	var six_p := RS.new()
	six_p.append_input(VInput.RIGHT)
	six_p.append_input(VInput.PUNCH)

	input_detector.add_sequence_input("6p", six_p)

	"""
	var input_history_display = $UI/InputHistoryDisplay
	#input_history_display.input_detector = $Player.input_detector
	input_history_display.input_id_visible = false
	input_history_display.set_input_texture(VInput.UP, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Up.png"))
	input_history_display.set_input_texture(VInput.DOWN, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Down.png"))
	input_history_display.set_input_texture(VInput.LEFT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Left.png"))
	input_history_display.set_input_texture(VInput.RIGHT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Right.png"))
	input_history_display.set_input_texture(VInput.UP_LEFT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Up_Left.png"))
	input_history_display.set_input_texture(VInput.UP_RIGHT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Up_Right.png"))
	input_history_display.set_input_texture(VInput.DOWN_RIGHT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Down_Right.png"))
	input_history_display.set_input_texture(VInput.DOWN_LEFT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Down_Left.png"))

	input_history_display.set_input_texture(VInput.KICK, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/PS4_Cross.png"))
	input_history_display.set_input_texture(VInput.PUNCH, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/PS4_Square.png"))
	input_history_display.set_input_texture(VInput.SLASH, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/PS4_Triangle.png"))
	input_history_display.set_input_texture(VInput.HEAVY_SLASH, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/PS4_Circle.png"))
	"""
	pass


func _process(delta):
	pass