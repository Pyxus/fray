tool
extends EditorScript

func _run() -> void:
	var interface := get_editor_interface()
	var current_path := interface.get_current_path()
	
	if current_path.is_valid_filename():
		OS.clipboard = 'preload("%s")' % current_path
		print("Imports copied to clipboard!")
	else:
		var dir := Directory.new()
		if dir.open(current_path) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			var clipboard := ""
			while file_name != "":
				if not dir.current_is_dir():
					clipboard += 'const %s = preload("%s")\n' % [file_name.get_basename().capitalize().replace(" ", ""), (current_path + file_name)]
				file_name = dir.get_next()
			OS.clipboard = clipboard
			print("Imports copied to clipboard!")
