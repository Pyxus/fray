extends "res://addons/stray_combat_framework/combat/2d/body/fighter_body_2d.gd"

const CombatFSM = preload("res://addons/stray_combat_framework/combat/state_management/combat_fsm.gd")
const InputDetector = preload("res://addons/stray_combat_framework/input/input_detector.gd")
const DetectedInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_input.gd")
const RootIdleState = preload("res://addons/stray_combat_framework/combat/state_management/states/root_idle_state.gd")
const SequenceData = preload("res://addons/stray_combat_framework/input/sequence/sequence_data.gd")

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

onready var combat_fsm: CombatFSM = get_node("CombatFSM")
onready var input_detector: InputDetector = get_node("InputDetector")


func _ready() -> void:
	input_detector.bind_action_input(VInput.UP, "up")
	input_detector.bind_action_input(VInput.DOWN, "down")
	input_detector.bind_action_input(VInput.LEFT, "left")
	input_detector.bind_action_input(VInput.RIGHT, "right")
	input_detector.bind_action_input(VInput.KICK, "kick")
	input_detector.bind_action_input(VInput.PUNCH, "punch")
	input_detector.bind_action_input(VInput.SLASH, "slash")
	input_detector.bind_action_input(VInput.HEAVY_SLASH, "heavy_slash")
	input_detector.register_combination(VInput.UP_LEFT, [VInput.UP, VInput.LEFT])
	input_detector.register_combination(VInput.UP_RIGHT, [VInput.UP, VInput.RIGHT])
	input_detector.register_combination(VInput.DOWN_LEFT, [VInput.DOWN, VInput.LEFT])
	input_detector.register_combination(VInput.DOWN_RIGHT, [VInput.DOWN, VInput.RIGHT])
	
	var qcf_hs := SequenceData.new()
	qcf_hs.append_inputs([VInput.DOWN, VInput.DOWN_RIGHT, VInput.RIGHT, VInput.HEAVY_SLASH])
	input_detector.register_sequence_from_data("236H", qcf_hs)

	var standing_punch := combat_fsm.create_action_vi("5P", VInput.PUNCH)
	var standing_slash := combat_fsm.create_action_vi("5S", VInput.SLASH)
	var qcf_heavy_slash := combat_fsm.create_action_si("236H", "236H")
	var standing_root := combat_fsm.create_situation("standing")
	standing_root.animation = "idle"
	standing_punch.chain_action(standing_slash)
	standing_root.chain_action(standing_punch)
	standing_root.chain_action(qcf_heavy_slash)
	
	combat_fsm.set_current_situation("standing")



func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	if "sequence_name" in detected_input:
		combat_fsm.buffer_input(detected_input)
	elif detected_input.is_pressed:
		combat_fsm.buffer_input(detected_input)
