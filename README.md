# Fray

<p align="center">
  <a href="https://godotengine.org">
    <img src="docs/fray_banner.png" width="500" alt="Godot Engine logo">
  </a>
</p>


![Fray status](https://img.shields.io/badge/status-alpha-red) ![Godot version](https://img.shields.io/badge/godot-v3.4-blue)  ![License](https://img.shields.io/badge/license-MIT-informational)

## 📖 About

Fray is a work in progress addon for the [Godot Game Engine](https://godotengine.org). It features tools for implementing action / fighting game style combat such as hit detection, input buffering, and fighter state management.

## ⚠️ IMPORTANT

**This addon is in alpha! Extensive testing is still required, breaking changes may still be made, and parts of the features below may not yet be fully implemented.**

## ✨ Core Features

### Hit Box Management

Fray provides tools for setting up and managing a fighter's hitbox / attackbox based on their current state.

### Combat State Management

Fray features a hiearchacel state machine that allows you to keep track of a fighter's combat state and automatically advance to new states based on the player's inputs. In other words this system lets you switch from one attack to another following a user defined "combat graph".

Through this system SCF supports the implementation of [chaining](https://glossary.infil.net/?t=Chain).

### Input Buffering

Inputs fed to fray's combat state management system are buffered allowing a player to queue their next action before the current action has finished. [Buffering](https://en.wiktionary.org/wiki/Appendix:Glossary_of_fighting_games#Buffering) is an important feature in action games as without it players would need frame perfect inputs to perform their actions.

### Complex Input Detection

Fray provides tools for detecting the 'complex' inputs featured in many fighting games such as [directional inputs](https://mugen.fandom.com/wiki/Command_input#Directional_inputs), [motion inputs](https://mugen.fandom.com/wiki/Command_input#Motion_input), [charged inputs](https://clips.twitch.tv/FuriousObservantOrcaGrammarKing-c1wo4zhroMVZ9I7y), and [sequence inputs](https://mugen.fandom.com/wiki/Command_input#Sequence_inputs).

## ⚙ Installation

1. Clone or download a copy of this repository.
2. Copy the contents of `addons/` into your `res://addons/` directory.
3. Enable `Fray - Combat Framework` in your project plugins.

If you would like to know more about installing plugins see the [Official Godot Docs](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).

## 📚 Documentation

- Getting Started (Coming Eventually)
- Fray API (Coming Eventually)

## 📃 Credits

### 🎨 Assets

- Controller Button Images : <https://thoseawesomeguys.com/prompts/>
- Player Example Sprite : <https://www.spriters-resource.com/playstation_2/mbaa/sheet/28116/>
