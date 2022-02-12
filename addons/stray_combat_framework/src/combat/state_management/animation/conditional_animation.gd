extends Resource

#TODO: Add support for queued animations,
# This is to support things such as a character playing an animation of them
# moving their arms up during a fall before switching to a continous animation
# of them falling in that pose

func _init(animation: String, activation_condition: Resource) -> void:
	self.animation = animation
	self.activation_condition = activation_condition

export var animation: String
export(Resource) var activation_condition: Resource
