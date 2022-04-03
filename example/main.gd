extends Node

const SequenceData = preload("res://addons/stray_combat_framework/src/new_input/sequence_data.gd")

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
	input_detector.bind_action_input(Btn.UP, "up")
	input_detector.bind_action_input(Btn.DOWN, "down")
	input_detector.bind_action_input(Btn.LEFT, "left")
	input_detector.bind_action_input(Btn.RIGHT, "right")
	input_detector.bind_action_input(Btn.KICK, "kick")
	input_detector.bind_action_input(Btn.PUNCH, "punch")
	input_detector.bind_action_input(Btn.SLASH, "slash")
	input_detector.bind_action_input(Btn.HEAVY_SLASH, "heavy_slash")
	input_detector.register_input_combination(Btn.DOWN_RIGHT, [Btn.DOWN, Btn.RIGHT], true)
	input_detector.register_input_combination(Btn.UP_LEFT, [Btn.UP, Btn.LEFT], true)
	input_detector.register_input_combination(Btn.UP_RIGHT, [Btn.UP, Btn.RIGHT], true)
	input_detector.register_input_combination(Btn.DOWN_LEFT, [Btn.DOWN, Btn.LEFT], true)
	input_detector.register_input_combination(Btn.DOWN_RIGHT, [Btn.DOWN, Btn.RIGHT], true)
	
	input_detector.register_sequence(SequenceData.new("qcfp", [Btn.DOWN, Btn.DOWN_RIGHT, Btn.RIGHT, Btn.PUNCH]))
	input_detector.register_sequence(SequenceData.new("dp", [Btn.RIGHT, Btn.DOWN, Btn.DOWN_RIGHT, Btn.PUNCH]))
	"""
	var input_history_display = $UI/InputHistoryDisplay
	#input_history_display.input_detector = $Player.input_detector
	input_history_display.input_id_visible = false
	input_history_display.set_input_texture(Btn.UP, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Up.png"))
	input_history_display.set_input_texture(Btn.DOWN, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Down.png"))
	input_history_display.set_input_texture(Btn.LEFT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Left.png"))
	input_history_display.set_input_texture(Btn.RIGHT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Right.png"))
	input_history_display.set_input_texture(Btn.UP_LEFT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Up_Left.png"))
	input_history_display.set_input_texture(Btn.UP_RIGHT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Up_Right.png"))
	input_history_display.set_input_texture(Btn.DOWN_RIGHT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Down_Right.png"))
	input_history_display.set_input_texture(Btn.DOWN_LEFT, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/Down_Left.png"))

	input_history_display.set_input_texture(Btn.KICK, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/PS4_Cross.png"))
	input_history_display.set_input_texture(Btn.PUNCH, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/PS4_Square.png"))
	input_history_display.set_input_texture(Btn.SLASH, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/PS4_Triangle.png"))
	input_history_display.set_input_texture(Btn.HEAVY_SLASH, preload("res://addons/stray_combat_framework/assets/sprites/input_buttons/PS4_Circle.png"))
	"""
	pass


func _process(delta):
	pass
