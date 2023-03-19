# Input Module

## Introduction

The input module provides tools which handle input detection, especially for the complex inputs that are typically found in fighting games such as [directional inputs](https://mugen.fandom.com/wiki/Command_input#Directional_inputs), [motion inputs](https://mugen.fandom.com/wiki/Command_input#Motion_input), [charged inputs](https://clips.twitch.tv/FuriousObservantOrcaGrammarKing-c1wo4zhroMVZ9I7y), and [sequence inputs](https://mugen.fandom.com/wiki/Command_input#Sequence_inputs).

## Registering Inputs to Input Map

Before you can make use of the other tools found in this module you must first register inputs to the input map. Inputs come in the form of binds which wrap around godot's input detection, and composites which make use of other composites to register inputs which involve multiple binds.

### Registering Binds

To register a bind you just need to call one of the add bind methods on fray's input map singleton. Several bind types exists but for this demonstration we will use the `FrayInputMap.add_bind_action()` method which makes use of godot actions. The method takes two arguments, a name for the bind which must be unique between binds and composites, and the name of the action you wish to bind.

Example:

```gdscript
# 'attack' is not a built-in action. I added it using Godot's input map.
FrayInputMap.add_bind_action("attack", "attack")
FrayInputMap.add_bind_action("right", "ui_right")
FrayInputMap.add_bind_action("left", "ui_left")
FrayInputMap.add_bind_action("up", "ui_up")
FrayInputMap.add_bind_action("down", "ui_down")
```

### Registering Composites

Composite inputs can be registered in a similar manner to binds using the `FrayInputMap.add_composite_input()` method. The method takes two arguments a name for the composite which must be unique between both composites and binds, and a composite object which can be built using the included builder classes. Fray comes with three composite inputs: Combinations, Conditionals, Groups, and Simple. Simple inputs are effectively just wrappers around binds and are used as the leafs of composition.

Simple inputs are essentialy a composite input wrapper around binds as binds can not diretly be components of a composite input.

Combination inputs are composed of 2 or more composite inputs and are triggered when their components are pressed. Combinations can be set to one of three modes: Sync which requires all components to be pressed at the same time, Async which requires all components to be pressed regarldess of time, and Ordered which requires all components to be pressed in the order they were added as components. In regards to fighting games these can be used to create the diagonal direction presses used in motion inputs in additional to just generally adding actions triggered by multiple button presses.

Conditional inputs change the input they represent based on a string condition defined in the input manager. In regards to fighting games this can be used to add inputs which change depending on the side you are standing on. For example If left of your opponent an attack may be activated with [right + square], If on right the same attack can then be activated with [left + square]. With conditional inputs this can generalized as being [forward + square] and simply update which side the player is on.

Group inputs are considered pressed when a minimum number of components in the group is pressed. This is useful for flexible inputs which require any of a certain set of buttons to be pressed. For example in guilty gear the Roman Cancel mechanic can be triggered by pressing any 3 attack buttons.

Examples:

```gdscript
# This describes an ordered combination of buttons. Both right and attack must be pressed however right must be pressed then attack. 
# Pressing it in reverse order will not work. This is the common behavior of the directional inputs present in fighting games.
FrayInputMap.add_composite_input("forward_punch", FrayCombinationInput.builder()
    .add_component(FraySimpleInput.from_bind("right"))
    .add_component(FraySimpleInput.from_bind("attack))
    .mode_ordered()
    .build()
)

# This describes an asynchronous combination of buttons. Both down and right must be pressed but the time and order of the presses do not matter. 
# Many fighting games make use of motion inputs which rely on treating combinations of directional buttons as real diagonal buttons on the controller
FrayInputMap.add_composite_input("down_right", FrayCombinationInput.builder()
    .add_component(FraySimpleInput.from_bind("down"))
    .add_component(FraySimpleInput.from_bind("right))
    .mode_async()
    # A virtual input will cause held binds to be repressed on release. 
    # This is useful for motion inputs since, for example, if you press down then down+right, then let go of down and just hold right
    # You'd want right to trigger a press even though technically you never pressed it again.
    .is_virtual()
    .build()
)

# This describes a combination input which changes based on what side the player is on.
# The condition is just a string name, the actual state of the condition must be updated on the 
# input singleton using `FrayInput.set_condition()`
FrayInputMap.add_composite_input("down_forward", FrayConditionalInput.builder()
	.add_component("", FrayCombinationInput.builder()
		.add_component(CIF.new_simple(["down"]))
		.add_component(CIF.new_simple(["right"])))
        .mode_async()
	.add_component("on_right", CIF.new_combination_async()
		.add_component(CIF.new_simple(["down"]))
		.add_component(CIF.new_simple(["left"])))
	.is_virtual()
	.build()
)

# Roman cancel is the name of a mechanic from the guilty gear series.
# It can be triggered by pressing any 3 attack buttons which this composite describes.
FrayInputMap.add_composite_input("roman_cancel", FrayGroupInput.builder()
    .add_component(FraySimpleInput.from_bind("attack1"))
    .add_component(FraySimpleInput.from_bind("attack2"))
    .add_component(FraySimpleInput.from_bind("attack3"))
    .add_component(FraySimpleInput.from_bind("attack4"))
    .min_pressed(3)
)
```

## Detecting Inputs

`FrayInput` is a singleton similar to the Input singleton provided by Godot. Once the input map is configured this manager can be used to check if binds and composites are pressed using their given names. Inputs can be checked per-device but by default all check methods use device 0 which usually corresponds to the keyboard/mouse and the 'player1' controller. The input manager also contains a 'input_detected' signal which can also be used to check for inputs similar to the input events fed through Godot's `_input()` virtual method.
    
```gdscript
FrayInput.is_pressed(...)
FrayInput.is_just_pressed(...)
FrayInput.is_just_released(...)
FrayInput.get_axis(...)
FrayInput.get_strength(...)
```

## Input Sequence Matching

Fray includes a sequence matcher which can be used for detecting sequences using a tree data structure to match inputs as they are fed to it. To use you will first need to create a `FraySequenceTree` which contains sequences associated with a string name. Each sequence name can be associated with multiple `FraySequenceBranch`s to allow for alternative inputs. Alternative inputs are useful for creating leniancy in a sequence by adding multiple matches for a given sequence name.

Example Usage:

```gdscript
var sequence_tree := FraySequenceTree.new()
var sequence_matcher := FraySequenceMatcher.new()

func _ready() -> void:
    # The following sequence describes the the input of the famous 'Hadouken' attack performed by Ryu from Street Fighters.
    sequence_tree.add("hadouken", FraySequenceBranch.builder()
        .first("down").then("down_right").then("right").then("attack")
        .build()
    )

    # This is an alternative input for the 'Hadoken' which can match even if the down_right is skipped.
    # Since this input is easier to perform you could balance this out by setting a short delay like 150ms
    sequence_tree.add("hadouken", FraySequenceBranch.builder()
        .first("down").then("right", 150).then("attack")
        .build()
    )

    # This sequence describes the Sonic Boom attack performed by Guile from Street Fighters.
    # This sequence is known as a "charge input" since it requires left to be held for 200ms before the rest of the sequence is performed.
    sequence_tree.add("sonic_boom", FraySequenceBranch.builder()
        .first("left", 200).then("right").then("attack")
        .build()
    )

    sequence_tree.initialize(sequence_tree)
```

For this example I named the sequences after the move names for the sake of explanation. However, I recommend choosing names which describe the sequences rather than conceptually "coupling" the name to a specific move. Sequences generally stay the same while moves and their names are subject to change. I recommend using the fighting game Numpad [Notation naming](https://www.dustloop.com/w/Notation) convention.

### Understanding Negative Edge

There is an input behavior featured in some fighting games known as negative edge. Ordinarily the input sequence is only considered valid when every button is pressed in succession. However, for inputs that support negative edge the last input in the sequence can be triggered by either a button press or a button release. Then means you can hold the last button down, enter the rest of the sequence, then release to trigger it.

Although this is niche, Fray does support it. You just need to set `is_negative_edge_enabled` to true or call the `enable_negative_edge()` when building your `FraySequenceBranch`s.

```gdscript
# The following sequence describes the the input of the famous 'Hadouken' attack performed by Ryu from Street Fighters.
sequence_tree.add("hadouken", FraySequenceBranch.builder()
    .first("down").then("down_right").then("right").then("attack").enable_negative_edge()
    .build()
)
```

### Detecting Sequence Matches

The sequence matcher uses fray input events for its match procedure. Events can be fed to the analyzer using the `FrayInput` singleton's `input_detected` signal. If a match is found the sequence matcher will emit a `match_found` signal.

```gdscript
func _ready() -> void:
    FrayInput.input_detected.connect(_on_FrayInput_input_detected)
    sequence_analyzer.match_found(_on_SequenceAnalyzer_match_found)

func _on_FrayInput_input_detected(input_event: Fray.Input.FrayInputEvent):
	sequence_analyzer.read(input_event)

func _on_SequenceAnalyzer_match_found(sequence_name: String):
	do_something_with_sequence(sequence_name)

```
