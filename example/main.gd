extends Node


func _ready() -> void:
		pass

func pack_sprites() -> void:
	var sprite_dir := "C:\\Users\\ezeha\\Downloads\\PlayStation 2 - Melty Blood Actress Again - Shiki Tohno\\shiki\\export"

	var dir := Directory.new()
	if dir.open(sprite_dir) == OK:
		if dir.list_dir_begin(true) == OK:
			var file := dir.get_next()
			while file != "":
				if file != "_sheets" and dir.dir_exists(file):
					var sprite_folder := dir.get_current_dir() + "/" + file
					var output_path := "'" + dir.get_current_dir() + "/_sheets/%s.png" % file + "'"
					var output = image_magick_montage(sprite_folder, output_path)
				file = dir.get_next()

func image_magick_montage(sprite_dir: String, output_path: String) -> Array:
	var output := []
	var magick_exe := "C:\\Program Files\\ImageMagick-7.1.0-Q16-HDRI\\magick.exe"
	var commands := [
		"cd '%s';" % sprite_dir, 
		"&'%s' montage -mode concatenate -background 'None' *.png %s" % [magick_exe, output_path],
	]
	var _exec_error = OS.execute("powershell.exe", commands, true, output)
	return output

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

