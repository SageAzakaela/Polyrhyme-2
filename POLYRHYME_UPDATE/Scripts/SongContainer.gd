extends GridContainer

const SONG_BUTTON = preload("res://Scenes/song_button.tscn")

func _ready():
	var song_dir_path = "res://Songs/"
	var dir = DirAccess.open(song_dir_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				var song_button = SONG_BUTTON.instantiate()
				# Assuming the button script has an exported "Song" property
				song_button.Song = song_dir_path + file_name
				add_child(song_button)
				song_button.text = file_name.replace(".tscn", "")
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: " + song_dir_path)
