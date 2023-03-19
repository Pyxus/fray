# Fray 2.0

<p align="center">
	<img src="assets/fray_banner.gif" alt="Fray Logo">
</p>


![Fray status](https://img.shields.io/badge/status-alpha-red) ![Godot version](https://img.shields.io/badge/godot-v4.0-blue)  ![License](https://img.shields.io/badge/license-MIT-informational)

## 📖 About

Fray is an addon for the [Godot Game Engine](https://godotengine.org) that provides tools which aid in the development of action / fighting game combat. If your project requires changes in combatant state corresponding to button presses, input buffering, handling complex player inputs, or hitbox management then you may benefit from using Fray!

## ⚠️ IMPORTANT

**Fray 2.0 is in alpha! Breaking changes may still be made.**

## ✨ Core Features

### Modular Design

Fray is divided into 3 modules: State Management, Input, and Collision. These modules act independent of one another and only communicate through string identifiers. These modules work independently of each other and only communicate through string identifiers, giving you the flexibility to use your own solutions alongside Fray's tools.

### State Management

Fray's combat state machine enables you to manage a fighter's state and transition to new states based on player inputs. With the combat state machine, you have improved control over combat flow, reducing the complexity of implementing state management. Transitions in the state machine can be easily enabled or disabled through code or in the animation player, enabling the implementation of [chaining](https://glossary.infil.net/?t=Chain), where attacks can be canceled into new attacks by allowing early transitions during attack animations.

State machines can be defined declaratively using the included builder classes.

```gdscript
# This example constructs a state machine which resembles:
# 	idle -[attack_button]> attack1 -[attack_button]> attack2
# 'attack_button' is an arbitray name.
combat_state_machine.add_situation("on_ground", RootState.builder()
	.transition_button("idle", "attack1", {input = "attack_button"})
	.transition_button("attack1", "attack2", {input = "attack_button"})
	.start_at("idle")
	.build()
)
```

### State Input Buffering

Inputs fed to fray's combat state machine are buffered allowing a player to queue their next action before the current action has finished. [Buffering](https://en.wiktionary.org/wiki/Appendix:Glossary_of_fighting_games#Buffering) is an important feature in action / fighting games as without it players would need frame perfect inputs to smoothly perform a sequence of actions.

Below is an example of how these inpust are fed to the state machine.

```gdscript
func _on_FrayInput_input_detected(input_event: Fray.Input.FrayInputEvent):
	if input_event.is_just_pressed():
		combat_state_machine.buffer_button(input_event.input, input_event.pressed)
```

### Complex Input Detection

Fray provides a component based input builder, and sequence matcher for handling the 'complex' inputs featured in many fighting games such as [directional inputs](https://mugen.fandom.com/wiki/Command_input#Directional_inputs), [motion inputs](https://mugen.fandom.com/wiki/Command_input#Motion_input), [charged inputs](https://clips.twitch.tv/FuriousObservantOrcaGrammarKing-c1wo4zhroMVZ9I7y), and [sequence inputs](https://mugen.fandom.com/wiki/Command_input#Sequence_inputs).

Composite inputs can be defined declaratively using the builder class internal of each composite class. 
These builders can be accessed through static `builder()` methods which return a new builder instance.

```gdscript
# Binds are used as the 'leafs' of composite input component trees.
FrayInputMap.add_bind_action("ui_right", "right")
FrayInputMap.add_bind_action("ui_down", "down")

# This describes a combination input which changes based on what side the player is on.
FrayInputMap.add_composite_input("down_forward", FrayConditionalInput.builder()
	.add_component("", FrayCombinationInput.builder()
		.mode_async()
		.add_component(CIF.new_simple(["down"]))
		.add_component(CIF.new_simple(["right"])))
	.add_component("on_right", CIF.new_combination_async()
		.add_component(CIF.new_simple(["down"]))
		.add_component(CIF.new_simple(["left"])))
	.is_virtual()
	.build()
)
```

Sequence inputs can be defined using the `SequenceTree` class, and then registered to the `SequenceMatcher`.
The sequence matcher can then be fed inputs and will emit a signal if any matches are found.

```gdscript
var sequence_tree := SequenceTree.new()

sequence_tree.add("236p", SequenceBranch.builder()
	.first("down").then("down_forward").then("forward").then("punch")
	.build()
)

# Sequence inputs can have multiple branches in order to support input leniency.
# To add a lenient version of the input simply add a new branch under the sequence name.
sequence_list.add("236p", SequenceBranch.builder()
	.first("down").then("forward").then("punch")
	.build()
)
```

```gdscript
# The sequence analyzer takes fray input events which are emitted by the FrayInput singleton
func _on_FrayInput_input_detected(input_event: Fray.Input.FrayInputEvent):
	sequence_analyzer.read(input_event)
```

### Hitbox Management

Fray provides a template hitbox which is an `Area` node with an `atrribute` property. Atrribute can be extended to determine the properties of the hitbox they are attached to. In addition, Fray provides tools for managing these hitboxes in the form of hit states. Hit states can control which hitbox child node is active through a single property in the inspector which can be keyed in animations for easy syncing.

<img src="assets/hitbox_tree.png" width="400" alt="Tree view of hitbox management">

<img src="assets/hit_state_inspector.png" width="400" alt="View of hit state inspector">

## 📦 Installation

1. Clone or download a copy of this repository.
2. Copy the contents of `addons/` into your `res://addons/` directory.
3. Enable `Fray - Combat Framework` in your project plugins.

If you would like to know more about installing plugins see the [Official Godot Docs](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).

## 📚 Documentation

- [Getting Started](./docs/getting_started/index.md)

## 📃 Credits

- Controller Button Images : <https://thoseawesomeguys.com/prompts/>
