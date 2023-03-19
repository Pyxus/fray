# Getting Started

Below you'll find introductions to each of  the given modules featured in Fray.

## Modules

- [Collision](./mod_collision/index.md)

- [Input](./mod_input/index.md)

- [State Management](./mod_state/index.md)

## Quickstart

Credit to Remi123 for sharing the snippet that this was based on.

```gdscript
class_name Fighter
extends KinematicBody2D

# Create SequenceTree and SequenceMatcher objetcs.
@onready var sequence_list := FraySequenceTree.new()
@onready var sequence_matcher := FraySequenceMatcher.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Register Godot inputs to frayinput.

    # I added one named 'attack' using Godot's input manager.
	FrayInputMap.add_bind_action("right", "ui_right")
	FrayInputMap.add_bind_action("left", "ui_left")
	FrayInputMap.add_bind_action("up", "ui_up")
	FrayInputMap.add_bind_action("down", "ui_down")
	FrayInputMap.add_bind_action("attack", "attack")

    # Register composite inputs

    # Composite inputs can be registered in a similar manner but they must be built.
    # Below describes an input which is a combination of down, and right that
    # conditionally changes to down, and left based on a 'on_right' condition.
    FrayInputMap.add_composite_input("down_forward", FrayConditionalInput.builder()
        .add_component("", FrayCombinationInput.builder()
			.add_component(FraySimpleInput.from_bind("down"))
			.add_component(FraySimpleInput.from_bind("right"))
			.mode_async()
			.build()
        )
        .add_component("on_right", FrayCombinationInput.builder()
			.add_component(FraySimpleInput.from_bind("down"))
			.add_component(FraySimpleInput.from_bind("left"))
			.mode_async()
			.build()
        )
        .is_virtual()
        .build()
    )

    # Describes an input which conditionally changes from left to right based on "on_right" condition.
    FrayInputMap.add_composite_input("forward", FrayConditionalInput.builder()
		.add_component("", FraySimpleInput.from_bind("right"))
		.add_component("on_right", FraySimpleInput.from_bind("left"))
		.build()
	)
	
    # Create sequences

    # The following sequence describes the the input of the famous 'Hadouken' attack.
    # performed by Ryu from Street Fighters.
    sequence_tree.add("hadouken", FraySequenceBranch.builder()
        .first("down").then("down_right").then("right").then("attack")
        .build()
    )

    # Simple charge move. This requires left to be held for 200ms before the rest of the sequence is performed.
    sequence_tree.add("sonic_boom", FraySequenceBranch.builder()
        .first("left", 200).then("right").then("attack")
        .build()
    )

    # Initializes the sequence matcher using the sequence tree.
	sequence_matcher.initialize(sequence_tree)
	
    # Send any inputs event to be read the sequence matcher
	FrayInput.input_detected.connect(sequence_matcher.read)

    # In case of a match event, print the name of the sequence. I use a callable here.
	sequence_matcher.match_found.connect(func(seq:StringName):
		print(seq)
		)
	
    # Print the sequence matcher's tree to view the input sequences it now matches.
	sequence_matcher.print_tree()

```