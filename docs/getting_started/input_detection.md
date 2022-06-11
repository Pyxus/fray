# Input Detection

This module contains tools related to input detection and processing. All related scripts can be found in the `fray/src/input` folder

## Input Manager

The imput manager is a singleton similar to the Input singleton provided by Godot. Once the input map is configured this manager can be used to check if inputs are pressed using their given ids. Inputs can be checked per-device but by default all check device 0 which usually corresponds to keyboard/mouse and the 'player1' controller. The input manager also contains a 'input_detected' signal which can also be used to check for inputs.

    FrayInput.is_pressed(...)
    FrayInput.is_just_pressed(...)
    FrayInput.is_just_released(...)
    FrayInput.get_axis(...)
    FrayInput.get_strength(...)

## Input Map

The input map is used to associate godot inputs with integer ids through the InputBind class; All inputs in Fray are checked using these ids. The map can also be used to create 'special inputs' which make use of these binds. 

These special inputs fall into 2 categories, combination and conditional.

### Combination Input

Combination inputs are composed of 2 or more input ids and triggered when the corresponding inputs are detected as pressed. They can be added to the input map with the `add_combination_input()` method. Combinations come in 3 types: SYNC which requires all components to be pressed at the same time, ASYNC which requires all components to be pressed regardless of time, ORDERED which requires all components to be pressed regardless of time so long as they are pressed in the order the components were provided.

In regards to fighting games this can be used to add the diagonal direction presses used in motion inputs, as well as in general adding actions triggered by pressing multiple buttons.
    const CombinationType = FrayInputNS.CombinationInput.Type
    enum Btn{
        DOWN,
        RIGHT,
        DOWN_RIGHT,
    }

    var input_map := FrayInput.get_input_map()
    input_map.add_combination_input(Btn.DOWN_RIGHT, [Btn.DOWN, Btn.RIGHT], true, CombinationType.ASYNC)
    # Here he passed true to enable 'press_held_components_on_release'
    # This means that when the combination is no longer considered as being pressed any held buttons it used as a component will be
    # treated as if they were just pressed. 
    # This is useful for motion inputs as this way you can press down -> down + right -> right without lifting your thumb

### Conditional Input

Conditional inputs change the input they are recognized as when a certain condition is true. They can be added to the input map with the `add_conditional_input()` method.

In regards to fighting games this can be used to add inputs which change depending on the side you are standing on. For example If left of your opponent an attack may be activated with [right + square], If on right the same attack can then be activated with [left + square]. With conditional inputs can can generalize this input as being [forward + square] and simply update which side the player is on.
    enum Btn{
        RIGHT,
        LEFT,
        FORWARD
    }

    var input_map := FrayInput.get_input_map()
    input_map.add_conditional_input(Btn.FORWARD, Btn.RIGHT, {"on_right":Btn.LEFT})
    ...
    # At this point if 'right' is pressed then forward would be considered press
    FrayInput.set_condition("on_right", true)
    # At this point if 'right' is pressed then forward woule not be considered press however it would be if left were pressed

## Sequence Analyzer

The sequence analyzer is used for detecting sequences within inputs. The default SequenceAnalyzer class is intentionally abstract to allow users to implement their own analyzers however Fray includes an implementation called the SequenceAnalyzerTree which uses a tree data structure to match inputs to a sequence.

To use you will first need to create a sequence collection which contains sequences associated with a string name. Each sequence name can be associated with multiple sequences to allow support for 'dirty' or 'graceful' inputs which are still read if not inputted perfectly.
    const SequenceCollection = FrayInputNS.SequenceCollection

    var collection := SequenceCollection.new()
    
    # Sequence can be built by passing arguments to constructor
    collection.add("236p", Sequence.new([Btn.DOWN, Btn.DOWN_BACKWARD, Btn.BACKWARD, Btn.PUNCH]))
    
    # Or with method calls which provide 
    # additional options for configuring the minimum time held (Useful for charge inputs)
    # and max delay (Useful for controlling required input speed)
    # Note: SequenceTreeAnalyzer currently does not support charged inputs and does not check the minimum time held property
    var dp_sequence := Sequence.new()
    dp_squence.append_input(Btn.RIGHT)
    dp_squence.append_input(Btn.DOWN)
    dp_squence.append_input(Btn.DOWN_FORWARD)
    dp_squence.append_input(Btn.SLASH)
    collection.add("DragonPunch)
