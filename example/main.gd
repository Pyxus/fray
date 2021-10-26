extends Node


func _ready() -> void:
	extract_melty_blood()

func extract_melty_blood() -> void:
	var directory := Directory.new()
	var error := directory.open("C:\\Users\\ezeha\\Downloads\\PlayStation 2 - Melty Blood Actress Again - Shiki Tohno\\shiki")
	
	if error == OK:
		directory.list_dir_begin(true)
		var make_error = directory.make_dir("export")
		var file := directory.get_next();file = directory.get_next()
		var prefix: String = file.left(file.find("_"))
		var copy_dir = "export/" + prefix
		directory.make_dir(copy_dir)
		while file != "":
			var new_prefix := file.left(file.find("_"))

			if prefix != new_prefix:
				prefix = new_prefix
				copy_dir = "export/" + prefix
				directory.make_dir(copy_dir)

			directory.copy(directory.get_current_dir() + "/" + file, directory.get_current_dir() + "/" + copy_dir + "/" + file)
			file = directory.get_next()
	else:
		print("SHELP")

