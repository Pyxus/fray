extends StrayCF.FighterBody2D

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

const CombatFSM = StrayCF.CombatFSM 
const Situation = StrayCF.Situation
const FighterState = StrayCF.FighterState
const InputDetector = StrayCF.InputDetector
const DetectedInput = StrayCF.DetectedInput
const SequenceData = StrayCF.SequenceData
const SequenceInputData = StrayCF.SequenceInputData
const VirtualInputData = StrayCF.VirtualInputData

onready var input_detector: InputDetector = get_node("InputDetector")
onready var combat_fsm: CombatFSM = get_node("CombatFSM")

func _ready() -> void:
	# Associate a virtual input, represented by an integer, with godot detectable input
	input_detector.bind_action_input(VInput.UP, "up")
	input_detector.bind_action_input(VInput.DOWN, "down")
	input_detector.bind_action_input(VInput.LEFT, "left")
	input_detector.bind_action_input(VInput.RIGHT, "right")
	
	# Fighting games often use special terms for their buttons to avoid
	# input association with a specific device.
	# These are the inputs to guilty gear and on a ps4 controller they mean Cross, Square, Triangle, Circle
	input_detector.bind_action_input(VInput.KICK, "kick")
	input_detector.bind_action_input(VInput.PUNCH, "punch")
	input_detector.bind_action_input(VInput.SLASH, "slash")
	input_detector.bind_action_input(VInput.HEAVY_SLASH, "heavy_slash")
	
	# Associate button presses with a combination input.
	# A combination is in effect an 'imaginary' input resulting from the press of 2 or more inputs.
	# Imaginary in that it is treated like an individual button on the device is being pressed.
	# Combinations are triggered when all buttons are pressed regardless of order.
	input_detector.register_combination(VInput.UP_LEFT, [VInput.UP, VInput.LEFT])
	input_detector.register_combination(VInput.UP_RIGHT, [VInput.UP, VInput.RIGHT])
	input_detector.register_combination(VInput.DOWN_LEFT, [VInput.DOWN, VInput.LEFT])
	input_detector.register_combination(VInput.DOWN_RIGHT, [VInput.DOWN, VInput.RIGHT])
	
	var sitch_on_ground := Situation.new("idle")
	var walk_forward_state := FighterState.new("walk_forward", "is_walking_forward")
	var walk_backward_state := FighterState.new("walk_backward", "is_walking_backward")
	var on_ground_root := sitch_on_ground.get_root()
	
	on_ground_root.connect_extender(walk_forward_state)
	on_ground_root.connect_extender(walk_backward_state)
	
	combat_fsm.add_situation("on_ground", sitch_on_ground)
	combat_fsm.set_current_situation("on_ground")

# Virtual method from FighterBody2D. If you choose to use this node for your fighters this is
# Where you should move them.
func _handle_movement(state: Physics2DDirectBodyState) -> void:
	combat_fsm.set_condition("is_walking_forward", false)
	combat_fsm.set_condition("is_walking_backward", false)
	
	if input_detector.is_input_pressed(VInput.RIGHT):
		state.linear_velocity.x = 300
		combat_fsm.set_condition("is_walking_forward", true)
	elif input_detector.is_input_pressed(VInput.LEFT):
		state.linear_velocity.x = -300
		combat_fsm.set_condition("is_walking_backward", true)
	

func _on_InputDetector_input_detected(detected_input: DetectedInput) -> void:
	pass # Replace with function body.


func _on_CombatFSM_state_changed(new_state: FighterState) -> void:
	pass # Replace with function body.
