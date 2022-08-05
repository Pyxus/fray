# Input Detection

This module contains tools related to input detection and processing.

Location: `fray/src/input`

## Input List

The `InputList` is a singleton used to register input binds, which are wrappers around godot inputs, and complex inputs, which are componet based inputs that use binds to compose an input. Before an input can be used by the input manager it must be registered under the input list.

Note: Though binds and complex input are technically different objects there can not be overlap in their names. A name given to a bind can not be used by a complex input and vice versa.

Example Usage:

    FrayInputList.add_bind_action("down", "ui_down")
    FrayInputList.add_bind_action("right", "ui_right")
    FrayInputList.add_complex_input("down_right", ...) # More on adding complex inputs below

## Complex Inputs

### ComplexInputFactory

The complex input factory is a static helper class which can create `ComplexInputBuilder`s to construct complex inputs in a more user friendly way. Using the builder you can avoid needing to directly refference and instantiate complex input classes.

Note all builder methods returns a reference to the builder itself to allow for optiona chaining.

Example Usage:

    const CIF = FrayInputNS.ComplexInputFactory
    const CombinationMode = FrayInputNS.CombinationInput.Mode

    FrayInputList.add_complex_input("down_right", CIF.new_combination()\
        .add_component(CIF.new_simple(["down"]))\
        .add_component(CIF.new_simple(["right"]))
        .mode(CombinationMode.ASYNC)
    )

### Simple Input

Simple inputs are essentialy a complex input wrapper around binds as binds can not diretly be components of a complex input.
One useful feature of simple inputs is they can be given multiple binds and will be considered pressed if any bind is triggered. An example of how this could be useful is burst in guilty gear which is triggered with a combination of R1 + [Any attack button].

### Combination Input

Combination inputs are composed of 2 or more complex inputs and are triggered when their components are detected by pressed. Combinations can be set to one of 3 modes: Sync which requires all components to be pressed at the same time, Async which requires all components to be pressed regarldess of time, and Ordered which requires all components to be pressed in the order they were added.

In regards to fighting games these can be used to create the diagonal direction presses used in motion inputs in additional to just generally adding actions triggered by multiple button presses.

### Conditional Input

Conditional inputs change the input they represent based on a string condition defined in the input manager.

In regards to fighting games this can be used to add inputs which change depending on the side you are standing on. For example If left of your opponent an attack may be activated with [right + square], If on right the same attack can then be activated with [left + square]. With conditional inputs this can generalized as being [forward + square] and simply update which side the player is on.

## Input Manager

The imput manager, called `FrayInput` is a singleton similar to the Input singleton provided by Godot. Once the input list is configured this manager can be used to check if inputs are pressed using their given names. Inputs can be checked per-device but by default all check device 0 which usually corresponds to keyboard/mouse and the 'player1' controller. The input manager also contains a 'input_detected' signal which can also be used to check for inputs.

    FrayInput.is_pressed(...)
    FrayInput.is_just_pressed(...)
    FrayInput.is_just_released(...)
    FrayInput.get_axis(...)
    FrayInput.get_strength(...)

## Sequence Analyzer

The sequence analyzer is used for detecting sequences using a tree data structure to match inputs as they are fed to it.

To use you will first need to create a `SequenceList` which contains sequences associated with a string name. Seach sequence name can be associated with multiple `SequencePath`s to allow for alternative inputs. Alternative inputs are useful for creating leniancy in a sequence by adding multiple matches for a sequence.

Example Usage:

    const SequenceList = FrayInputNS.SequenceList
    const SequencePath = FrayInputNS.SequencePath
    const SequenceAnalyzer = FrayInputNS.SequenceAnalyzer

    var sequence_list := SequenceList.new()
    var sequence_analyzer := SequenceAnalyzer.new()
    sequence_list.add("236P", SequencePath.new()\
        .add("down")
        .add("down_right")
        .add("right")
        .add("punch")
    )

    sequence_analyzer.initialize(sequence_list)

    # Look up 'fighting game notation' if you wish to understand the numbers I used in the sequence name
    # This is just a naming convention, any string can be used as a name.