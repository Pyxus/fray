class_name Fray
extends Object
## A collection of static helper functions and constants

## Converts time in [kbd]frames[/kbd] to time in milliseconds.
## [br]
## One frame is equal to 1 / [member Engine.physics_ticks_per_second]
## if [kbd]fps[/kbd] is a value less than 1.
static func frames_to_msec(frames: int, fps: int = -1) -> int:
	fps = Engine.physics_ticks_per_second if fps <= 0 else fps
	return floor((frames / float(Engine.physics_ticks_per_second)) * 1000)

## Converts time in [kbd]milliseconds[/kbd] to time in frames.
## [br]
## One frame is equal to 1 / [member Engine.physics_ticks_per_second]
## if [kbd]fps[/kbd] is a value less than 1.
static func msec_to_frames(msec: int, fps: int = -1) -> int:
	fps = Engine.physics_ticks_per_second if fps <= 0 else fps
	return ceil((Engine.physics_ticks_per_second * msec) / 1000.0)

## Converts time in [kdb]milliseconds[/kbd] to time in seconds.
static func msec_to_sec(msec: int) -> float:
	return msec / 1000.0

## Converts time in [kdb]seconds[/kbd] to time in milliseconds.
static func sec_to_msec(sec: float) -> int:
	return roundi(sec * 1000)