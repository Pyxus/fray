extends StrayCF.RigidFighterBody2D

const InputButtonCondition = StrayCF.InputButtonCondition
const InputSequenceCondition = StrayCF.InputSequenceCondition
const CombatFSM = StrayCF.CombatFSM
const CombatState = StrayCF.CombatState
const CombatSituationFSM = StrayCF.CombatSituationFSM
const CombatSituationState = StrayCF.CombatSituationState
const CombatTransition = StrayCF.CombatTransition
const SequenceData = StrayCF.SequenceData

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
	RIGHT_PUNCH,
	FORWARD,
}

onready var input_detector: StrayCF.InputDetector = get_node("InputDetector")
onready var combat_tree: StrayCF.CombatTree = get_node("CombatTree")
onready var ground_cast: RayCast2D = get_node("GroundCast")
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

var max_jump_count: int = 1
var jump_count: int = 0

func _ready() -> void:
	Engine.time_scale = .8

	# Set up inputs
	input_detector.connect("input_detected", self, "_on_InputDetector_input_detected")
	input_detector.bind_action_input(Btn.UP, "up")
	input_detector.bind_action_input(Btn.DOWN, "down")
	input_detector.bind_action_input(Btn.LEFT, "left")
	input_detector.bind_action_input(Btn.RIGHT, "right")
	input_detector.bind_action_input(Btn.KICK, "kick")
	input_detector.bind_action_input(Btn.PUNCH, "punch")
	input_detector.bind_action_input(Btn.SLASH, "slash")
	input_detector.bind_action_input(Btn.HEAVY_SLASH, "heavy_slash")
	
	input_detector.register_combination_input(Btn.RIGHT_PUNCH, [Btn.RIGHT, Btn.PUNCH], true)
	input_detector.register_combination_input(Btn.DOWN_RIGHT, [Btn.DOWN, Btn.RIGHT], false, true)
	input_detector.register_combination_input(Btn.UP_LEFT, [Btn.UP, Btn.LEFT], false, true)
	input_detector.register_combination_input(Btn.UP_RIGHT, [Btn.UP, Btn.RIGHT], false, true)
	input_detector.register_combination_input(Btn.DOWN_LEFT, [Btn.DOWN, Btn.LEFT], false, true)
	input_detector.register_combination_input(Btn.DOWN_RIGHT, [Btn.DOWN, Btn.RIGHT], false, true)
	
	input_detector.sequence_analyzer.add_sequence(SequenceData.new("214P", [Btn.DOWN, Btn.DOWN_LEFT, Btn.LEFT, Btn.PUNCH]))
	input_detector.sequence_analyzer.add_sequence(SequenceData.new("214P", [Btn.DOWN, Btn.LEFT, Btn.PUNCH]))
	input_detector.sequence_analyzer.add_sequence(SequenceData.new("236P", [Btn.DOWN, Btn.DOWN_RIGHT, Btn.RIGHT, Btn.PUNCH]))
	input_detector.sequence_analyzer.add_sequence(SequenceData.new("623P", [Btn.RIGHT, Btn.DOWN, Btn.DOWN_RIGHT, Btn.PUNCH]))
	input_detector.sequence_analyzer.add_sequence(SequenceData.new("236P214S", [Btn.DOWN, Btn.DOWN_RIGHT, Btn.RIGHT, Btn.PUNCH, Btn.DOWN, Btn.DOWN_LEFT, Btn.LEFT, Btn.SLASH]))
	
	# Input Conditions
	var punch_input_condition := InputButtonCondition.new(Btn.PUNCH)
	var slash_input_condition := InputButtonCondition.new(Btn.SLASH)
	var heavy_input_condition := InputButtonCondition.new(Btn.HEAVY_SLASH)
	var kick_input_condition := InputButtonCondition.new(Btn.KICK)
	
	# On Ground State Machine
	var on_ground_fsm := CombatFSM.new()
	on_ground_fsm.add_state("Idle", CombatState.new(["neutral"]))
	on_ground_fsm.add_state("5P", CombatState.new(["normal"]))
	on_ground_fsm.add_state("5S", CombatState.new(["normal"]))
	on_ground_fsm.add_state("5K", CombatState.new(["normal"]))
	on_ground_fsm.add_state("5H", CombatState.new(["normal"]))
	on_ground_fsm.add_state("5S-5S", CombatState.new(["normal"]))
	on_ground_fsm.add_state("214P", CombatState.new(["special"]))
	on_ground_fsm.add_transition("Idle", "5P", CombatTransition.new(punch_input_condition))
	on_ground_fsm.add_transition("Idle", "5S", CombatTransition.new(slash_input_condition))
	on_ground_fsm.add_transition("Idle", "5K", CombatTransition.new(kick_input_condition))
	on_ground_fsm.add_transition("Idle", "5H", CombatTransition.new(heavy_input_condition))
	on_ground_fsm.add_transition("5S", "5S-5S", CombatTransition.new(slash_input_condition))
	on_ground_fsm.add_transition("5S", "5H", CombatTransition.new(heavy_input_condition))
	on_ground_fsm.add_transition("5H", "5K", CombatTransition.new(kick_input_condition))
	on_ground_fsm.add_global_transition_rule("normal", "special")
	on_ground_fsm.add_global_transition_rule("neutral", "special")
	on_ground_fsm.add_global_transition("214P", CombatTransition.new(InputSequenceCondition.new("214P")))
	on_ground_fsm.initial_state = "Idle"
	on_ground_fsm.initialize()

	# Situation State Machine
	var state_machine := CombatSituationFSM.new()
	state_machine.add_state("OnGround", CombatSituationState.new(on_ground_fsm))
	state_machine.initial_state = "OnGround"
	state_machine.initialize()

	combat_tree.state_machine = state_machine

	var _disable_warning = combat_tree.connect("combat_state_changed", self, "_on_CombatTree_combat_state_changed")


func _process(_delta) -> void:
	var combat_fms = combat_tree.state_machine.get_combat_fsm()

	match combat_fms.current_state:
		"Idle":
			if input_detector.is_input_pressed(Btn.RIGHT):
				animation_player.play("walk_forward")
			elif input_detector.is_input_pressed(Btn.LEFT):
				animation_player.play("walk_backward")
			else:
				animation_player.play("idle")
		"5P":
			animation_player.play("5p")
		"5S":
			animation_player.play("5s")
		"5H":
			animation_player.play("5h")
		"5S-5S":
			animation_player.play("5s-5s")
		"214P":
			animation_player.play("214p")
		"5K":
			animation_player.play("5k")
		var matchless_state:
			push_warning("Current state '%s' has no match set" % matchless_state)


func is_on_floor(find_immediate: bool = false):
	if ground_cast.is_colliding():
		return true
	return .is_on_floor(find_immediate)

"""
func _handle_movement(state: Physics2DDirectBodyState) -> void:
	._handle_movement(state)
	
	combat_fsm.set_all_conditions(false)
	input_detector.press_checks_enabled = true
	speed_on_slope = 300

	if jump_count < max_jump_count:
		if input_detector.is_input_just_pressed(VInput.UP_RIGHT):
			state.linear_velocity = Vector2.ZERO
			apply_impulse(Vector2.ZERO, Vector2(300, -1200))
			jump_count += 1
		elif input_detector.is_input_just_pressed(VInput.UP_LEFT):
			state.linear_velocity = Vector2.ZERO
			apply_impulse(Vector2.ZERO, Vector2(-300, -1200))
			jump_count += 1
		elif input_detector.is_input_just_pressed(VInput.UP):
			state.linear_velocity = Vector2.ZERO
			apply_impulse(Vector2.ZERO, Vector2(0, -1200))
			jump_count += 1

	if is_on_floor(true):
		combat_fsm.set_condition("is_on_ground", true)
		jump_count = 0
		
		if not combat_fsm.is_current_state_root():
			input_detector.press_checks_enabled = false
		
		if not is_force_resolution_allowed():
			if input_detector.is_input_pressed(VInput.RIGHT):
				state.linear_velocity.x = 300
				combat_fsm.set_condition("is_walking_forward", true)
			elif input_detector.is_input_pressed(VInput.LEFT):
				state.linear_velocity.x = -300
				combat_fsm.set_condition("is_walking_backward", true)
			else:
				state.linear_velocity.x = 0
				pass
	else:
		combat_fsm.set_condition("is_in_air", true)
		
		if state.linear_velocity.y > 0:
			if state.linear_velocity.x < -0.1:
				combat_fsm.set_condition("is_falling_backward", true)
			elif state.linear_velocity.x > 0.1:
				combat_fsm.set_condition("is_falling_forward", true)
		else:
			if state.linear_velocity.x < -0.1:
				combat_fsm.set_condition("is_jumping_backward", true)
			elif state.linear_velocity.x > 0.1:
				combat_fsm.set_condition("is_jumping_forward", true)
				
			if input_detector.is_input_just_pressed(VInput.UP_LEFT):
				combat_animation_player.reset()
			elif input_detector.is_input_just_pressed(VInput.UP_RIGHT):
				combat_animation_player.reset()
"""

func _on_InputDetector_input_detected(detected_input) -> void:
	pass

func _on_CombatTree_combat_state_changed(from: String, to: String) -> void:
	#print("State changed %s->%s" % [from, to])
	pass
