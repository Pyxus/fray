# Input Module

## Introduction

The input module provides tools which handle input detection, particularly for the complex inputs that are typically found in fighting games such as [directional inputs](https://mugen.fandom.com/wiki/Command_input#Directional_inputs), [motion inputs](https://mugen.fandom.com/wiki/Command_input#Motion_input), [charged inputs](https://clips.twitch.tv/FuriousObservantOrcaGrammarKing-c1wo4zhroMVZ9I7y), and [sequence inputs](https://mugen.fandom.com/wiki/Command_input#Sequence_inputs).

## Registering Inputs to Input Map

In order to utilize most of the features offered by this module, you need to register inputs to the input map. These inputs can take the form of either binds or composites. Binds wrap around Godot's input detection, while composites use other composites to compose inputs that involve multiple binds.

### Registering Input Binds

To register a bind, simply call one of the `add_bind` methods on Fray's input map singleton. There are several types of binds available, but for this demonstration, we'll be using `FrayInputMap.add_bind_action()`, which utilizes Godot actions. This method requires two arguments: a  unique name for the bind (which must be unique between both composites and binds), and the name of the action you wish to bind.

Example:

```gdscript
FrayInputMap.add_bind_action("attack", "your_custom_godot_action")
FrayInputMap.add_bind_action("right", "ui_right")
FrayInputMap.add_bind_action("left", "ui_left")
FrayInputMap.add_bind_action("up", "ui_up")
FrayInputMap.add_bind_action("down", "ui_down")
```

### Registering Composite Inputs

You can register composite inputs using the `FrayInputMap.add_composite_input()` method, similar to how binds are registered. The method requires two arguments: a unique name for the composite (which must be unique between both composites and binds) and a composite object, which can be built with the included builder classes. Fray includes four composite inputs: Combinations, Conditionals, Groups, and Simple.

- Simple inputs are essentially a composite input wrapper around binds since binds cannot be components of a composite input directly.

- Combination inputs are composed of two or more composite inputs and are triggered when their components are pressed. Combinations can be set to one of three modes: Sync, which requires all components to be pressed at the same time; Async, which requires all components to be pressed regardless of time; and Ordered, which requires all components to be pressed in the order they were added as components. In the context of fighting games, combination inputs can be used to create the diagonal direction presses used in motion inputs, in addition to generally adding actions triggered by multiple button presses.

- Conditional inputs change the input they represent based on string conditions defined in the `FrayInput` input manager. In the context of fighting games, conditional inputs can be used to add inputs that change depending on the side of the player. For example, if the player is on the left side of the opponent, an attack may be activated with [right +  attack_button]. If the player is on the right side, the same attack can then be activated with [left + attack_button]. With conditional inputs, this can be generalized as [forward +  attack_button] and the 'player side' condition updates to change the physical button 'forward' uses.

- Group inputs are considered pressed when a minimum number of components in the group is pressed. This is useful for flexible inputs that require any of a certain set of buttons to be pressed.

Examples:

```gdscript
# This describes an ordered combination of buttons where 'right' must be pressed, and then 'attack' must be pressed. Pressing them in reverse order will not work. 
# This is the behavior of the directional inputs present in fighting games.
FrayInputMap.add_composite_input("forward_punch", FrayCombinationInput.builder()
    .add_component(FraySimpleInput.from_bind("right"))
    .add_component(FraySimpleInput.from_bind("attack"))
    .mode_ordered()
    .build()
)

# This describes an asynchronous combination of buttons where both 'down' and 'right' must be pressed, but the order and timing of the presses do not matter. 
# Many fighting games make use of motion inputs that rely on treating combinations of directional buttons as diagonal buttons.
FrayInputMap.add_composite_input("down_right", FrayCombinationInput.builder()
    .add_component(FraySimpleInput.from_bind("down"))
    .add_component(FraySimpleInput.from_bind("right"))
    .mode_async()
    # A virtual input will cause held binds to be repressed upon release. 
    # This is useful for motion inputs:
    # For example, if you press [down] then [down + right], and then release [down] but continue to hold [right] 
    # you want [right] to trigger a press even though you technically never pressed it again. 
    # Otherwise, you would have to manually release [right] and press it again, which interrupts the "motion" of the motion input.
    .is_virtual()
    .build()
)

# This uses a conditional input to describe a combination input that changes based on what side the player is on. 
# The condition is just an arbitrary string name, and the actual state of the condition 
# must be updated on the input singleton using the `FrayInput.set_condition()` method.
FrayInputMap.add_composite_input("down_forward", FrayConditionalInput.builder()
  # The first component does not require a condition since it is considered the default component.
	.add_component("", FrayCombinationInput.builder()
		.add_component(FraySimpleInput.from_bind("down"))
		.add_component(FraySimpleInput.from_bind("right"))
    .mode_async()
	.add_component("on_right", FrayCombinationInput.builder()
		.add_component(FraySimpleInput.from_bind("down"))
		.add_component(FraySimpleInput.from_bind("left"))
    .mode_async()
	.is_virtual()
	.build()
)

# This is registering a roman cancel input from the Guilty Gear series.
# It can be triggered by pressing any 3 attack buttons, which is a behavior this group input describes.
FrayInputMap.add_composite_input("roman_cancel", FrayGroupInput.builder()
    .add_component(FraySimpleInput.from_bind("attack1"))
    .add_component(FraySimpleInput.from_bind("attack2"))
    .add_component(FraySimpleInput.from_bind("attack3"))
    .add_component(FraySimpleInput.from_bind("attack4"))
    .min_pressed(3)
    .build()
)
```

## Detecting Inputs

`FrayInput` is a singleton similar to Godot's `Input` singleton. After configuring the input map, this manager can be used to check if binds and composites are pressed using their assigned names. While inputs can be checked per-device, the default behavior is to use device 0, which typically corresponds to the keyboard/mouse and the 'player1' controller. The input manager also contains an `input_detected` signal, which can be used to detect inputs in a similar manner to Godot's built-in `_input()` virtual method.

Examples:

    
```gdscript
FrayInput.is_pressed("input_name")
FrayInput.is_just_pressed("input_name")
FrayInput.is_just_released("input_name")
FrayInput.get_axis("negative_input_name", "positive_input_name")
FrayInput.get_strength("input_name")

func _on_FrayInput_input_dected(event: FrayInputEvent) -> void:
  if event.input == "input_name" and event.is_pressed:
    do_something()

```

## Input Sequence Matching

Fray provides a sequence matcher that can be used to detect input sequences. To use this feature, you first need to create a `FraySequenceTree` object, which contains a mapping of sequence names to branch objects. Each sequence name can be associated with multiple `FraySequenceBranch` objects, which allow for alternative inputs. Alternative inputs are useful for creating leniency in a sequence by adding multiple matches for a given sequence name.

Example Usage:

```gdscript
var sequence_tree := FraySequenceTree.new()
var sequence_matcher := FraySequenceMatcher.new()

func _ready() -> void:
    # The following sequence describes the input for Ryu's famous 'Hadouken' attack.
    sequence_tree.add("hadouken", FraySequenceBranch.builder()
        .first("down").then("down_right").then("right").then("attack")
        .build()
    )

    # It can be frustating as a player for an attack to not be performed because of overly strict inputs.
    # This is an alternative input for the 'Hadoken' which can match even if the 'down_right' is skipped.
    # This supports leniency by catching the case where a player accidently releases 'down' before pressing 'right'.
    sequence_tree.add("hadouken", FraySequenceBranch.builder()
        .first("down").then("right").then("attack")
        .build()
    )

    # This sequence describes Guile's Sonic Boom attack.
    # This type of sequence is known as a "charge input" since it requires 'left' to be held for a certain amount of time, 200ms in this example, before the rest of the sequence is performed.
    sequence_tree.add("sonic_boom", FraySequenceBranch.builder()
        .first("left", 200).then("right").then("attack")
        .build()
    )

    sequence_matcher.initialize(sequence_tree)
```

In this example, I've named the sequences after the moves for the sake of clairty. However, while sequences generally stay the same, moves and their names are subject to change. For this reason it's recommend to choose names which describe the sequences rather than the move. A recommended naming convention is the Numpad Notation used in fighting games, which provides a clear and concise way to describe inputs using numbers that correspond to directions on a numeric keypad. You can find more information about Numpad Notation at https://www.dustloop.com/w/Notation.

### Understanding Negative Edge

In some fighting games, there is a special input behavior known as negative edge. Typically, an input sequence is considered valid only when every input is pressed in succession. However, for sequences that support negative edge, the last input in the sequence can be triggered by either a input press or a input release. This means that you can hold the last input in the sequence down, enter the rest of the sequence, and then release it to complete the sequence and trigger the attack. Fray supports this feature, and you can enable it by calling the `enable_negative_edge()` method when building your `FraySequenceBranch` objects.

Example Usage:

```gdscript
# The following sequence describes the input for Ryu's famous 'Hadouken' attack.
sequence_tree.add("hadouken", FraySequenceBranch.builder()
    .first("down").then("down_right").then("right").then("attack")
    .enable_negative_edge()
    .build()
)
```

### Using Sequence Matcher

To perform the match procedure, the sequence matcher uses `FrayInputEvent`s. You can feed events to the matcher using the `FrayInput` singleton's `input_detected` signal. If a matching sequence is found, the matcher will emit a `match_found` signal.

Example Usage:

```gdscript
var sequence_matcher := SequenceMatcher.new()

func _ready() -> void:
    FrayInput.input_detected.connect(_on_FrayInput_input_detected)
    sequence_matcher.match_found(_on_SequenceMatcher_match_found)

func _on_FrayInput_input_detected(input_event: Fray.Input.FrayInputEvent) -> void:
	sequence_matcher.read(input_event)

func _on_SequenceMatcher_match_found(sequence_name: String) -> void:
	do_something_with_sequence(sequence_name)

```
