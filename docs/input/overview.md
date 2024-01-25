---
layout: doc
outline: [2, 6]
---

# Input Module

## Purpose of the Module

Action games, particularly fighting games, often associate combatant actions with various input combiatnions. Fray provides its own input singleton, offering a component-based approach to describing composite inputs. Additionally, Fray provides a sequence matcher capable of detecting input sequences.

## What Is a Composite Input?

A composite input is a combination of two or more atomic inputs. Examples of composite inputs commonly found in fighting games include [directional inputs](https://mugen.fandom.com/wiki/Command_input#Directional_inputs), [motion inputs](https://mugen.fandom.com/wiki/Command_input#Motion_input), [charged inputs](https://clips.twitch.tv/FuriousObservantOrcaGrammarKing-c1wo4zhroMVZ9I7y), and [sequence inputs](https://mugen.fandom.com/wiki/Command_input#Sequence_inputs).
