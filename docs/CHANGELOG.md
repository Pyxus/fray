# Changelog

## v1.0.0-alpha.3

### Added

- Added new combination builders to `ComplexInputFactory` class.
- Added new InputBindFrayAction. This allows you to create a bind using simple binds in a way that mimic's Godot's actions.
- Added new class icons.
- Added "situation_changed" signal on `CombatStateMachine`.
- Added ability to set combat state instance in `CombatSituationBuilder`.
- Added 'active_hitboxes' flag to `HitState2D` and `HitState3D`

### Changed

- Updated hit detection system.
- Renamed 'hit_detection' folder to more general 'collision'.
- Replaced individual module pseudo-namespaces with 1 namespace. Now instead of `FrayInputNS` you would type `Fray.Input`.
- Most input binds now inherit from new InputBindSimple type.
- Renamed `CombatGraph` to `CombatStateMachine`.
- Renamed `HitStateSwitcher` to `HitStateManager`.
- Exposed "add_state" method in `CombatSituationBuilder`.
- Updated state machine library to be more flexible. States now have new 'enter', 'process', and 'exit' virtual methods that are invokved by the state machine.

### Removed

- Removed push box. There will no longer be a default push box implementation, users can create their own depending on their collision set up.
- Removed `CombatGraphData` class.
- Removed "state_changed" signal on `CombatStateMachine`.

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

- Removed 'expression' and 'node_path' property from `EvaluatedCondition` class. They will be reimplemented in a later version.

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
