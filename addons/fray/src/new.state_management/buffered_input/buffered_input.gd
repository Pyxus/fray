extends Resource
## Base buffered input class
##
## @desc:
##		A buffered input is an input which has been detected but won't be executed until a later point.

func _init(input_time_stamp: int = 0) -> void:
	time_stamp = input_time_stamp

var time_stamp: int
