class_name Fray
extends Object
## A list of static helper functions and constants

## Converts time in [kbd]frames[/kbd] to time in ms.
## [br]
## One frame is equal to 1 / [member Engine.physics_ticks_per_second]
## if [kbd]fps[/kbd] is a value less than 1.
static func frames_to_ms(frames: int, fps: int = -1) -> int:
	fps = Engine.physics_ticks_per_second if fps <= 0 else fps
	return ceil((Engine.physics_ticks_per_second * frames) / 1000.0)

## Converts time in [kbd]ms[/kbd] to time in frames.
## [br]
## One frame is equal to 1 / [member Engine.physics_ticks_per_second]
## if [kbd]fps[/kbd] is a value less than 1.
static func ms_to_frames(frames: int, fps: int = -1) -> int:
	fps = Engine.physics_ticks_per_second if fps <= 0 else fps
	return floor((frames / float(Engine.physics_ticks_per_second)) * 1000)
