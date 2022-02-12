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



onready var input_detector: StrayCF.InputDetector = get_node("InputDetector")
onready var combat_fsm: StrayCF.CombatFSM = get_node("CombatFSM")
onready var ground_cast: RayCast2D = get_node("GroundCast")

var max_jump_count: int = 1
var jump_count: int = 0

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
	
	var qcb_p_sequence := StrayCF.SequenceData.new()
	qcb_p_sequence.append_inputs([VInput.DOWN, VInput.DOWN_LEFT, VInput.LEFT, VInput.PUNCH])
	input_detector.register_sequence_from_data("214P", qcb_p_sequence)

	var sitch_on_ground := StrayCF.Situation.new()
	var on_ground_root := sitch_on_ground.get_root()
	var neutral_punch := StrayCF.CombatState.new()
	var neutral_slash := StrayCF.CombatState.new()

	var punch_input_data := StrayCF.VirtualInputData.new(VInput.PUNCH)

	neutral_punch.chain_to(neutral_punch, punch_input_data)
	on_ground_root.chain_to(neutral_punch, punch_input_data)
	combat_fsm.add_situation(sitch_on_ground)
	combat_fsm.set_situation(sitch_on_ground)

	"""
	# This is all basically boilerplate for the combatFSM
	# A fighter's state needs to exist within situations such as "on ground", "in air", "being hit"
	var sitch_on_ground := Situation.new("idle")
	var on_ground_root := sitch_on_ground.get_root()
	var walk_forward_state := FighterState.new("walk_forward", "is_walking_forward")
	var walk_backward_state := FighterState.new("walk_backward", "is_walking_backward")
	var neutral_punch := FighterState.new("5p")
	var neutral_slash := FighterState.new("5s")
	var neutral_slash_neutral_slash := FighterState.new("5s-5s")
	var neutral_heavy := FighterState.new("5h")
	var neutral_kick := FighterState.new("5k")
	var qcb_punch := FighterState.new("214p")

	# A chain is a connection from one state to another where change between states occur if the correct input is provided
	# Chains can be used to make combos
	neutral_punch.chain(neutral_slash, VirtualInputData.new(VInput.SLASH))
	neutral_slash.chain(neutral_heavy, VirtualInputData.new(VInput.HEAVY_SLASH))
	neutral_slash.chain(neutral_slash_neutral_slash, VirtualInputData.new(VInput.SLASH))
	neutral_heavy.chain(neutral_kick, VirtualInputData.new(VInput.KICK))
	
	# Global chains are chains to global states which can be accessed from any state in the situation.
	# Global states are identified by tags. A state opts in to visiting a global state by chaining its tags.
	# Global states can be used to make 'specials' and 'supers'
	neutral_punch.chain_global("special")
	neutral_slash.chain_global("special")
	neutral_heavy.chain_global("special")
	neutral_kick.chain_global("special")
	
	#on_ground_root.chain(neutral_punch, VirtualInputData.new(VInput.PUNCH)) TODO: Add input priority system. P keeps being processed during 214P
	
	# Global states exist within the root but in order to be accessed from the root the root must also opt in with chain global
	on_ground_root.add_global_chain("special", qcb_punch, SequenceInputData.new("214P"))
	on_ground_root.chain_global("special")
	on_ground_root.chain(neutral_slash, VirtualInputData.new(VInput.SLASH))
	on_ground_root.chain(neutral_heavy, VirtualInputData.new(VInput.HEAVY_SLASH))
	on_ground_root.chain(neutral_kick, VirtualInputData.new(VInput.KICK))
	
	# Extension allows 1 state to act as a sub state of another.
	# An extender will be able to visit the connections of the extendee.
	# And an extender node is visited so longs as its active condition is true.
	# This is to allow for things such as being able to punch both in the standing state and walking state
	# Without having to connect the punch state to both.
	on_ground_root.connect_extender(walk_forward_state)
	on_ground_root.connect_extender(walk_backward_state)
	
	var sitch_in_air := Situation.new("jump_neutral")
	var in_air_root := sitch_in_air.get_root()
	var jump_backward_state := FighterState.new("jump_backward", "is_jumping_backwards")
	var jump_forward_state := FighterState.new("jump_forward", "is_jumping_forwards")
	var fall_neutral_state := FighterState.new("fall_neutral", "is_falling")
	var fall_backward_state := FighterState.new("fall_backward", "is_falling_backwards")
	var fall_forward_state := FighterState.new("fall_forward", "is_falling_forwards")
	var j5p_state := FighterState.new("j5p")
	var j5s_state := FighterState.new("j5s")
	var j5h_state := FighterState.new("j5h")
	
	in_air_root.chain(j5p_state, VirtualInputData.new(VInput.PUNCH))
	in_air_root.chain(j5s_state, VirtualInputData.new(VInput.SLASH))
	in_air_root.chain(j5h_state, VirtualInputData.new(VInput.HEAVY_SLASH))
	in_air_root.connect_extender(fall_backward_state)
	in_air_root.connect_extender(fall_forward_state)
	in_air_root.connect_extender(fall_neutral_state)
	in_air_root.connect_extender(jump_forward_state)
	in_air_root.connect_extender(jump_backward_state)
	
	combat_fsm.add_situation("in_air", sitch_in_air)
	combat_fsm.add_situation("on_ground", sitch_on_ground)
	combat_fsm.set_current_situation("on_ground")
	"""

func is_on_floor(find_immediate: bool = false):
	if ground_cast.is_colliding():
		return true
	return .is_on_floor(find_immediate)

# Virtual method from FighterBody2D. If you choose to use this node for your fighters this is
# Where you should move them.
func _handle_movement(state: Physics2DDirectBodyState) -> void:
	"""
	combat_fsm.set_all_conditions_false()

	if combat_fsm.is_current_state_root_or_extension():
		input_detector.press_checks_enabled = true
	else:
		input_detector.press_checks_enabled = false

	if jump_count < max_jump_count:
		if input_detector.is_input_just_pressed(VInput.UP_RIGHT):
			state.linear_velocity.y = -1200
			state.linear_velocity.x = 300
			jump_count += 1
		elif input_detector.is_input_just_pressed(VInput.UP_LEFT):
			state.linear_velocity.y = -1200
			state.linear_velocity.x = -300
			jump_count += 1
		elif input_detector.is_input_just_pressed(VInput.UP):
			state.linear_velocity.y = -1000
			state.linear_velocity.x = 0
			jump_count += 1
			
	if combat_fsm.get_current_state().animation != "214p": 
		if is_on_floor():
			jump_count = 0
			combat_fsm.set_current_situation("on_ground")
			
			if input_detector.is_input_pressed(VInput.RIGHT):
				state.linear_velocity.x = 300
				combat_fsm.set_condition("is_walking_forward", true)
			elif input_detector.is_input_pressed(VInput.LEFT):
				state.linear_velocity.x = -300
				combat_fsm.set_condition("is_walking_backward", true)
			else:
				state.linear_velocity.x = 0
				#state.linear_velocity.y = 0
		else:
			combat_fsm.set_current_situation("in_air")
			
			if state.linear_velocity.y >= 0:
				combat_fsm.set_condition("is_falling", true)
				
				if state.linear_velocity.x < 0:
					combat_fsm.set_condition("is_falling_backwards", true)
				elif state.linear_velocity.x > 0:
					combat_fsm.set_condition("is_falling_forwards", true)
			else:
				if state.linear_velocity.x < 0:
					combat_fsm.set_condition("is_jumping_backwards", true)
				elif state.linear_velocity.x > 0:
					combat_fsm.set_condition("is_jumping_forwards", true)
	"""

# Buffers inputs to the CombatFSM allowing chains to advance.
func _on_InputDetector_input_detected(detected_input: StrayCF.DetectedInput) -> void:
	combat_fsm.buffer_input(detected_input)


func _on_CombatFSM_state_changed(from: StrayCF.CombatState, to:StrayCF.CombatState) -> void:
	print(from, to)
