extends Reference
# This only exists because I wanted an easy way to sort and pack some files for my example
# If you'd like to make use of this for some reason you'll need to install ImageMagick
# and set the executable path in this script.
# https://imagemagick.org/index.php

# Example Usage:
# var dir := "C:\\sprite_directory"
# ImageMagickUtil.extract(dir, "ryo\\d\\d")
# ImageMagickUtil.pack_extracted_sprites(dir + "/" + "extract")

const IMAGE_MAGIC_EXE_PATH = "C:\\Program Files\\ImageMagick-7.1.0-Q16-HDRI\\magick.exe"

static func pack_extracted_sprites(extract_dir: String, extension: String = "png") -> void:
	var dir := Directory.new()
	var error = dir.open(extract_dir)
	var sheet_output_dir := "_sheets"
	if error == OK:
		if dir.list_dir_begin(true) == OK:
			var file := dir.get_next()
			if not dir.dir_exists(sheet_output_dir):
				dir.make_dir(sheet_output_dir)
			while not file.empty():
				if file != "_sheets" and dir.current_is_dir():
					var sprite_folder := dir.get_current_dir() + "/" + file
					var output_path := "'" + dir.get_current_dir() + "/%s/%s.%s" % [sheet_output_dir, file, extension] + "'"
					var output = image_magick_montage(sprite_folder, output_path, extension)
				file = dir.get_next()
	else:
		push_error("Failed to open dir '%s'. Error: %d" % [extract_dir, error])
				
static func image_magick_montage(sprite_dir: String, output_path: String, extension: String = "png") -> Array:
	var output := []
	var commands := [
		"cd '%s';" % sprite_dir, 
		"&'%s' montage -mode concatenate -background 'None' *.%s %s" % [IMAGE_MAGIC_EXE_PATH, extension, output_path],
	]
	var _exec_error = OS.execute("powershell.exe", commands, true, output)
	return output

static func extract(dir: String, prefix_format: String, extract_dir: String = "extract") -> void:
	var directory := Directory.new()
	var error := directory.open(dir)
	
	if error == OK:
		directory.list_dir_begin(true)
		
		if not directory.dir_exists(extract_dir):
			error = directory.make_dir(extract_dir)
			
		if error == OK:
			var regex := RegEx.new()
			regex.compile("^%s" % prefix_format)
			
			var file := directory.get_next()
			while not file.empty():
				if not directory.current_is_dir():
					var result := regex.search(file)
					if result != null:
						var prefix := result.get_string()
						var file_path := directory.get_current_dir() + "/" + file
						var image_copy_dir := directory.get_current_dir() + "/" + extract_dir + "/" + prefix
						var image_copy_path := image_copy_dir + "/" + file
						if not directory.dir_exists(image_copy_dir):
							error = directory.make_dir(image_copy_dir)
							if error != OK:
								push_error("Failed to create image dir '%s'. Error: %d" % [image_copy_dir, error])
						error = directory.copy(file_path, image_copy_path)
						if error != OK:
							push_error("Failed to copy file '%s' to '%s'. Error: %d" % [file_path, image_copy_path, error])
					pass
				file = directory.get_next()
		else:
			push_error("Failed to make extraction directory. Error: %d" % error)
	else:
		push_error("Failed to open directory '%s'. Error: %d" % [dir, error])
