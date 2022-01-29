extends "res://addons/stray_combat_framework/src/combat/2d/body/fighter_body_2d.gd"

const CombatFSM = preload("res://addons/stray_combat_framework/src/combat/combat_fsm.gd")
const Situation = preload("res://addons/stray_combat_framework/src/combat/situation.gd")
const FighterState = preload("res://addons/stray_combat_framework/src/combat/fsm_states/fighter_state.gd")
const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const SequenceData = preload("res://addons/stray_combat_framework/src/input/sequence/sequence_data.gd")
const SequenceInputData = preload("res://addons/stray_combat_framework/src/combat/fsm_states/input_data/sequence_input_data.gd")
const VirtualInputData = preload("res://addons/stray_combat_framework/src/combat/fsm_states/input_data/virtual_input_data.gd")

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
	
	# Configuring Detector
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
	
	# Configuring States
	var neutral_slash := FighterState.new()
	neutral_slash.animation = "5S"
	neutral_slash.chain_global("special")
	
	
	var neutral_punch := FighterState.new()
	neutral_punch.animation = "5P"
	neutral_punch.chain_global("special")

	
	var walk_forward := FighterState.new()
	walk_forward.animation = "walk"
	walk_forward.active_condition = "is_walking_forward"

	var qcf_heavy_slash := FighterState.new()
	qcf_heavy_slash.animation = "236H"
	qcf_heavy_slash.global_tag = "special"

	var walk_backward := FighterState.new()
	walk_backward.animation = "walk_back"
	walk_backward.active_condition = "is_walking_back"
	
	neutral_punch.chain(neutral_slash, VirtualInputData.new(VInput.SLASH))
	
	var situation_on_ground := Situation.new()
	var ground_root := situation_on_ground.get_root()
	ground_root.chain_global("special")
	ground_root.add_global_chain("special", qcf_heavy_slash, SequenceInputData.new("236H"))
	ground_root.connect_extender(walk_forward)
	ground_root.connect_extender(walk_backward)
	ground_root.chain(neutral_punch, VirtualInputData.new(VInput.PUNCH))
	ground_root.chain(neutral_slash, VirtualInputData.new(VInput.SLASH))
	ground_root.animation = "idle"

	combat_fsm.add_situation("on_ground", situation_on_ground)
	combat_fsm.set_current_situation("on_ground")
	pass


func _process(_delta: float) -> void:
	if input_detector.is_input_pressed(VInput.LEFT):
		combat_fsm.set_condition("is_walking_back", true)
		combat_fsm.set_condition("is_walking_forward", false)
	elif input_detector.is_input_pressed(VInput.RIGHT):
		combat_fsm.set_condition("is_walking_forward", true)
		combat_fsm.set_condition("is_walking_back", false)
	else:
		combat_fsm.set_condition("is_walking_forward", false)
		combat_fsm.set_condition("is_walking_back", false)

func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	combat_fsm.buffer_input(detected_input)
	pass
