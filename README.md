# Fray

<p align="center">
	<img src="assets/images/fray_banner.gif" alt="Fray Logo">
</p>

![Fray status](https://img.shields.io/badge/status-alpha-red) ![Godot version](https://img.shields.io/badge/godot-v4.2+-blue) ![License](https://img.shields.io/badge/license-MIT-informational)

## 📖 About

Fray is a modular Godot 4 addon designed to aid in the development of action-oriented games. It offers solutions for combatant state management, complex input detection, input buffering, and hitbox organization. If your project requires any of these functionalities you may benefit from using Fray.

## ⚠️ IMPORTANT

**Fray is currently in an alpha state.**

What does this mean?

- It has not been tested rigorously enough for me to be comfortable recommending it for use in a serious project.

- The documentation is incomplete and there is a lack of good examples.

- Lastly, it is still susceptible to refactors, meaning the API is subject to change.

That being said, a significant portion of Fray is functional, with any remaining bugs likely being simple oversights rather than major design flaws. If these issues do not concern you, and/or you are interested in testing the framework, please feel free to explore!



## ✨ Core Features

### Resource-Based Hierarchical State Machine

- Build state machines declaratively in code using the included builder class.

- Control state transitions using callable transition prerequisites and advance conditions.

- Extend states and transitions to further control state flow and/or encapsulate game behavior within different states.


[comment]: <Make a new animation which show cases a more fighting-game relevant animation AND sub states. Maybe on ground and in air>

### Composite Input Detection 

- Declaratively describe the many composite inputs featured in action / fighting games ([directional inputs](https://mugen.fandom.com/wiki/Command_input#Directional_inputs), [motion inputs](https://mugen.fandom.com/wiki/Command_input#Motion_input), [charged inputs](https://clips.twitch.tv/FuriousObservantOrcaGrammarKing-c1wo4zhroMVZ9I7y), and [sequence inputs](https://mugen.fandom.com/wiki/Command_input#Sequence_inputs)) using component based approach.

- Check defined inputs anywhere using included input singleton.

[comment]: <Make animation which shows code on left, controller on the bottom highlighting the combined inputs, and example of executing input in game on right.>


### Hitbox management

- Define hitboxes using template class with extendable attributes resource.

- Organize hitboxes using hit states and hit state managers. 

- Key active hitboxes in animation player using a single property for easier timeline management.

[comment]: <Show gif of hitbox organization>

## 📚 Getting Started

Fray comes with comprehensive documentation integrated with Godot 4's documentation comments. This means you can access explanations for classes and functions directly within the Godot editor.

For additional guides and resources, check out the [official Fray wiki](https://fray.pyxus.dev).

## 📦 Installation

1. Clone or download a copy of this repository.
2. Copy the contents of the repo into `res://addons/fray` directory.
3. Enable `Fray - Combat Framework` in your project plugins.

If you would like to know more about installing plugins see the [Official Godot Docs](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).

## 📃 Credits

- Controller Button Images : <https://thoseawesomeguys.com/prompts/>
