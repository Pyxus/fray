class_name Fray
extends Object
## A collection of static helper functions and constants

## Converts time in [kbd]frames[/kbd] to time in milliseconds.
## [br]
## One frame is equal to 1 / fps 
## [br]
## if [kbd]fps[/kbd] is a value less than or equal to 0 then fps defaults to [member Engine.physics_ticks_per_second].
static func frame_to_msec(frames: int, fps: int = -1) -> int:
	fps = Engine.physics_ticks_per_second if fps <= 0 else fps
	return floori((frames / float(Engine.physics_ticks_per_second)) * 1000)

## Converts time in [kbd]msec[/kbd] to time in frames.
## [br]
## One frame is equal to 1 / fps 
## [br]
## if [kbd]fps[/kbd] is a value less than or equal to 0 then fps defaults to [member Engine.physics_ticks_per_second].
static func msec_to_frame(msec: int, fps: int = -1) -> int:
	fps = Engine.physics_ticks_per_second if fps <= 0 else fps
	return ceili((Engine.physics_ticks_per_second * msec) / 1000.0)

## Converts time in [kbd]frames[/kbd] to time in seconds.
## [br]
## One frame is equal to 1 / fps 
## [br]
## if [kbd]fps[/kbd] is a value less than or equal to 0 then fps defaults to [member Engine.physics_ticks_per_second].
static func frame_to_sec(frames: int, fps: int = -1) -> int:
	fps = Engine.physics_ticks_per_second if fps <= 0 else fps
	return floori(frames / float(Engine.physics_ticks_per_second))

## Converts time in [kbd]sec[/kbd] to time in frames.
## [br]
## One frame is equal to 1 / fps 
## [br]
## if [kbd]fps[/kbd] is a value less than or equal to 0 then fps defaults to [member Engine.physics_ticks_per_second].
static func sec_to_frame(sec: int, fps: int = -1) -> int:
	fps = Engine.physics_ticks_per_second if fps <= 0 else fps
	return ceili(Engine.physics_ticks_per_second * sec)

## Converts time in [kdb]milliseconds[/kbd] to time in seconds.
static func msec_to_sec(msec: int) -> float:
	return msec / 1000.0

## Converts time in [kdb]seconds[/kbd] to time in milliseconds.
static func sec_to_msec(sec: float) -> int:
	return roundi(sec * 1000)