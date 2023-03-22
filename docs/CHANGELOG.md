# Changelog

## v2.0.0-alpha

### Added

- Collision: Added exported `source` property to `FrayHitState` 2D/3D.

- Input: Added `FrayGroupInput` composite input.

- Input: Added EXPERIMENTAL input buffer node. The way in which this node functions is very subject to change.

- State Management: Added general purpose `FrayGeneralStateMachine`.

### Changed

- Switched from using `String`s to `StringName`s in various places such as for input and state names.

- Switched from using packed arrays to godot 4's new typed arrays in various places.

- Gave every class a class_name prefixed with `Fray`.

- Changed functionally read-only `is_X` variables to methods.

- Collision: Renamed `HitboxAttributes` to `FrayHitboxAttribute`.

- Input: Changed `FraySimpleInput` to use a single bind rather than an array of binds. The features related to the simple input having multiple binds have now been spread between `FrayInputBindFrayAction` and `FrayGroupInput`.

- Input: Replaced `CompositeInputFactory` with builder classes internal to each composite input. Builders can be created with a static method call like so `FrayCombinationInput.builder()`.

- Input: Renamed `SequenceList` to `FraySequenceTree`.

- Input: Renamed `SequencePath` to `FraySequenceBranch`.

- Input: Renamed `SequenceAnalyzer` to `FraySequenceMatcher`.

- State Management: Changed state builder transition config to now directly check the properties of `FrayStateMachineTransition` objects. Any object property can be used as a dict key in order to set the value when building.

- State Management: Renamed 'state' module folder to 'state_mgmt'.

- State Management: Renamed `StateNode` to `FrayState`.

- State Management: Replaced `StateNodeStateMachine` and `StateNodeStateMachineGlobal` with `FrayRootState`. This new class has the functionality of both.

- State Management: Replaced all use of 'node' with 'state'. For example what was previously `StateNodeStateMachine.add_node()` is now `FrayRootState.add_state()`.

- State Management: Replaced state machine builders with internal builder on `FrayRootState`. The builder can be created with a static method call like so `FrayRootState.builder()`.

- State Management: Made `FrayStateMachine` node pseudo-abstract. Its functionality is now implemented in `FrayGeneralStateMachine`.

### Fixed

- Resolved issues with in-line doc comments. Many doc comments were written prior to Godot 4, they've been updated to correctly display in the in-engine documentation.

- Fixed several documentation typos.

- Rewrote 'getting started' documentation to fix typos and provide a better introduction into Fray.

### Removed

- Removed pseudo-namespaces: `Fray.StateMgt`, `Fray.Input`, and `Fray.Collision`. In order to take advantage of class referencing in doc comments and exporting custom resource types all classes must now use actual class names.

### Fixed

## v1.0.1

### Removed

- Removed `*.import` gitignore

## v1.0.0

### Added

- Added `ignore_indistinct_inputs` property to `SequenceAnalyzer`.
- Added `get_match_path()` method to `SequenceAnalyzer`.

### Changed

- Changed state machine 'go_to' functions to 'goto'.
- Refactored input filtration. `FrayInputEvent` `filtered` property is now replaced by `is_distinct`.
- Renamed `SequencePath` `add()` method to `then()`.
- Changed `CombatStateMachine` input buffer from buffering states to only buffering inputs which go to the next state when allowed.

### Removed

- Removed `match_path` parameter from `SequenceAnalyzer` `match_found` signal.

### Fixed

- Fixed global transitions not being reachable.

## v1.0.0-alpha.4

### Added

- Added `device_connection_changed` signal to `FrayInput`

- Added `Controller` node to input module.

- Added animation state machine to state module

### Changed

 - Completely reworked state management. The state module now includes a generic hiearchical state machine which is accessible to the user.

 - Renamed module from 'state_management' to 'state'.

 - Input binds can now implement a `get_strength()` method.

 - Virtual device can now set strength in the `press()` method.

### Fixed

- Fixed inability to load plugin due to `VirtualDevice` referencing `FrayInput` singleton.

 - Fixed inability to use `FrayInput.get_strength()` with virtual devices. The method now checks the strength stored in input state instead of directly checking Godot's `Input` singleton.


## v1.0.0-alpha.3

### Added

- Added new combination builders to `ComplexInputFactory` class.

- Added new InputBindFrayAction. This allows you to create a bind using simple binds in a way that mimic's Godot's actions.

- Added new class icons.

- Added "situation_changed" signal on `CombatStateMachine`.

- Added ability to set combat state instance in `CombatSituationBuilder`.

- Added `active_hitboxes` flag to `HitState2D` and `HitState3D`.

- Added ability to create virtual devices in `FrayInput` singleton.

- Added `is_any_pressed()` method to `FrayInput` singleton.

- Added `is_device_connected()` method to `FrayInput` singleton.

- Added ability to remove binds and complex inputs from `FrayInputList`.

### Changed

- Updated hit detection system.

- Renamed 'hit_detection' folder to more general 'collision'.

- Replaced individual module pseudo-namespaces with 1 namespace. Now instead of `FrayInputNS` you would type `Fray.Input`.

- Most input binds now inherit from new InputBindSimple type.

- Renamed `CombatGraph` to `CombatStateMachine`.

- Renamed `HitStateSwitcher` to `HitStateManager`.

- Exposed `add_state` method in `CombatSituationBuilder`.

- Updated state machine library to be more flexible. States now have new 'enter', 'process', and 'exit' virtual methods that are invokved by the state machine.

- HitboxAttribute' `can_detect` method now takes attribute instead of hitbox.

- The `CombatStateMachine` will now default to using the first added situation.

- Renamed `FrayInputList` back to `FrayInputMap` to mirror Godot's naming 

### Removed

- Removed push box. There will no longer be a default push box implementation, users can create their own depending on their collision set up.
- Removed `CombatGraphData` class.

- Removed `state_changed` signal on `CombatStateMachine`.

- Removed `current_state` proprety from `HitStateManager2D` and `HitStateManager3D`. State will now be activated when active hitboxes are set.

### Fixed

- InputBindJoyAxis not reading axis correctly.

- Fixed 3d nodes extending `Node2D` instead of `Spatial`.

- Fixed lack of null checks on `FrayInput` methods.

## v1.0.0-alpha.2

### Fixed

- Memory leaks related to inner class cyclic dependency and cyclic references in complex input.

## v1.0.0-alpha

### Added

- Added `CombatSituationBuilder` to make constructing combat situations in code easier.

- Added `CombatGraphData` to hold all situation state machines associated with a name.

- Added `ComplexInput` to replace old 'special' inputs.

- Added `ComplexInputFactory` to make constructing complex inputs in code easier.

- Added support for charged inputs through the updated `SequenceAnalyzer`. This allows for an input sequence to require that the first button in the sequence be held for a certain amount of time in order to satisfy the sequence.

- Added support for negative edge through the updated `SequenceAnalyzer`. This optionally allows for the release of a button to satisfy the last input in a sequence.

### Changed

- Updated the doc comments of several classes.

- Updated `FrayInputEvent` to inlcude more information on an input's state such as the frame at which a press occured. Additionally added helper methods to calculate certain things such as the how long an input was held.

- Replaced combination and conditional inputs with component based alternative reffered to as a `ComplexInput`. The previous system allowed for inputs to reference other inputs which could result in cyclic dependencies. Complex inputs only make reference to input binds which are atomic.

- Removed `expression` and `node_path` property from `EvaluatedCondition` class. They will be reimplemented in a later version.

- Renamed all input binds classes from `(NameHere)InputBind` to `InputBind(NameHere)`.

- Changed `CombatGraph` to work with new `CombatGraphData` class rather than directly setting combat situation.

- Changed `SequenceAnalyzer`. The previouse SequenceAnalyzerTree implementation was redesigned and merged with the `SequenceAnalyzer` class.

- Changed 'state' folder to 'state_management'.

- Changed `FrayCombatState` namespace to `FrayStateMgmt`.

- Renamed `SequenceCollection` to `SequenceList`.

- Renamed `Sequence` to `SequecnePath`.

- Renamed `FrayInputMap` singleton to `FrayInputList`.

### Fixed

- `EvaluatedCondition`'s string condition not being evaluated.

### Deprecated

- All scripts related to hit detection are pending redesign.

### Removed

- Removed SequenceAnalyzerTree.

## v0.1 - Experimental Release
