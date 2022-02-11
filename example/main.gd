extends Node

const ImageMagickUtil = preload("res://addons/stray_combat_framework/lib/image_magick_util.gd")

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

var dict: Dictionary

func _ready() -> void:
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
