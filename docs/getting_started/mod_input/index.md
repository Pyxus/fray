# Input Module

## Introduction

This module contains scripts related to input detection and processing.

## Input Map

The `InputMap` is a singleton used to register input binds, which are wrappers around godot inputs, and composite inputs, which are componet based inputs that use binds to compose an input. Before an input can be used by the input manager it must be registered under the input list.

Note: Though binds and composite input are technically different objects there can not be overlap in their names. A name given to a bind can not be used by a composite input and vice versa.

Example Usage:

```swift
FrayInputMap.add_bind_action("down", "ui_down")
FrayInputMap.add_bind_action("right", "ui_right")
FrayInputMap.add_composite_input("down_right", ...) # More on adding composite inputs below
```

## Composite Inputs

### CompositeInputFactory

The composite input factory is a static helper class which can create `CompositeInputBuilder`s to construct composite inputs in a more user friendly way. Using the builder you can avoid needing to directly refference and instantiate composite input classes.

All builder methods returns a reference to the builder itself to allow for optional method chaining.

Example Usage:

```swift
const CIF = Fray.Input.CompositeInputFactory
const CombinationMode = Fray.Input.CombinationInput.Mode

FrayInputMap.add_composite_input("down_right", CIF.new_combination()\
    .add_component(CIF.new_simple(["down"]))\
    .add_component(CIF.new_simple(["right"]))
    .mode(CombinationMode.ASYNC)
)
```

### Simple Input

Simple inputs are essentialy a composite input wrapper around binds as binds can not diretly be components of a composite input.
One useful feature of simple inputs is they can be given multiple binds and will be considered pressed if any bind is triggered. An example of how this could be useful is burst in guilty gear which is triggered with a combination of R1 + [Any attack button].

### Combination Input

Combination inputs are composed of 2 or more composite inputs and are triggered when their components are detected by pressed. Combinations can be set to one of 3 modes: Sync which requires all components to be pressed at the same time, Async which requires all components to be pressed regarldess of time, and Ordered which requires all components to be pressed in the order they were added.

In regards to fighting games these can be used to create the diagonal direction presses used in motion inputs in additional to just generally adding actions triggered by multiple button presses.

### Conditional Input

Conditional inputs change the input they represent based on a string condition defined in the input manager.

In regards to fighting games this can be used to add inputs which change depending on the side you are standing on. For example If left of your opponent an attack may be activated with [right + square], If on right the same attack can then be activated with [left + square]. With conditional inputs this can generalized as being [forward + square] and simply update which side the player is on.

## Input Manager

The imput manager, called `FrayInput` is a singleton similar to the Input singleton provided by Godot. Once the input list is configured this manager can be used to check if inputs are pressed using their given names. Inputs can be checked per-device but by default all check device 0 which usually corresponds to keyboard/mouse and the 'player1' controller. The input manager also contains a 'input_detected' signal which can also be used to check for inputs.
    
```swift
FrayInput.is_pressed(...)
FrayInput.is_just_pressed(...)
FrayInput.is_just_released(...)
FrayInput.get_axis(...)
FrayInput.get_strength(...)
```

## Sequence Analyzer

The sequence analyzer is used for detecting sequences using a tree data structure to match inputs as they are fed to it.

To use you will first need to create a `SequenceList` which contains sequences associated with a string name. Seach sequence name can be associated with multiple `SequencePath`s to allow for alternative inputs. Alternative inputs are useful for creating leniancy in a sequence by adding multiple matches for a sequence.

Example Usage:

```swift
const SequenceList = Fray.Input.SequenceList
const SequencePath = Fray.Input.SequencePath
const SequenceAnalyzer = Fray.Input.SequenceAnalyzer

var sequence_list := SequenceList.new()
var sequence_analyzer := SequenceAnalyzer.new()
sequence_list.add("236P", SequencePath.new()\
    .then("down").then("down_right").then("right").then("punch")
)

sequence_analyzer.initialize(sequence_list)
```

Look up 'fighting game notation' if you wish to understand the numbers I used in the sequence name. This is just a naming convention, any string can be used as a name.
