extends ScrollContainer

@export var bpm: float = 120.0  # BPM of the song
@export var default_file_name: String = ""  # Default file name, can be overwritten by the user
@export var JSON_PATH: String = ""
const MEASURE_ROW = preload("res://measure_row.tscn")
@onready var track = $"../Track"
@onready var vbox_container = $VboxContainer
@onready var song_slider = $"../SongTransport"  # Reference to the VSlider
@onready var save_json_file = $"../Save_JSON_File"
@onready var play_track = $"../PlayTrack"
@onready var pause_track = $"../PauseTrack"
@onready var stop_track = $"../StopTrack"
@onready var enable_loop = $"../EnableLoop"
@onready var begin_loop = $"../BeginLoop"
@onready var end_loop = $"../EndLoop"



@export var guitar_enabled: bool = false
@export var ignore_off_beats: bool = false
@export var song_to_play: AudioStream
var song_data: Array = []
var current_beat: int = 0
var playing: bool = false
var paused: bool = false
var beat_interval: float = 0.0
var vbox_child_count: int = 0
var vbox_minimum_size: float = 0
var total_rows : int = 0
var recently_saved_song = ""

func _ready():
	track.stream = song_to_play
	populate_beats()
	if JSON_PATH != "":
		load_json()

	scroll_vertical = vbox_container.get_minimum_size().y  # Set the scroll bar to the bottom initially
	song_slider.max_value = vbox_container.get_child_count() - 1
	song_slider.value = 0  # Start slider at the end
	vbox_child_count = vbox_container.get_child_count()
	vbox_minimum_size = vbox_container.get_minimum_size().y


func load_json():
	var song_to_load = FileAccess.open(JSON_PATH, FileAccess.READ)
	if song_to_load:
		var obj = JSON.new()
		var json_str = song_to_load.get_as_text()
		obj.parse(json_str)
		song_data = obj.get_data()
		song_to_load.close()
		print("loading JSON")

		for note_data in song_data:
			var note_time = note_data["time"]
			var note_key = note_data["key"]

			# Calculate the correct beat index
			var beat_index = int(note_time / beat_interval)

			if beat_index < vbox_container.get_child_count():
				var beat_row = vbox_container.get_child(beat_index)
				toggle_button(beat_row, note_key)

	else:
		print("Failed to load JSON")

func toggle_button(beat_row, note_key):
	var button = null
	match note_key:
		"a": button = beat_row.a
		"q": button = beat_row.a
		"s": button = beat_row.s
		"w": button = beat_row.s
		"d": button = beat_row.d
		"e": button = beat_row.d
		"f": button = beat_row.f
		"r": button = beat_row.f
		"j": button = beat_row.j
		"u": button = beat_row.j
		"k": button = beat_row.k
		"i": button = beat_row.k
		"l": button = beat_row.l
		"o": button = beat_row.l
		";": button = beat_row._semicolon
		"p": button = beat_row._semicolon

	if button:
		button.button_pressed = true  # Ensure the button is turned on
		
		# Check if the note key is one of the high notes
		if note_key in ["q", "w", "e", "r", "u", "i", "o", "p"]:
			button.text = "High"
		else:
			button.text = ""  # Set to no text


func _physics_process(_delta):
	if playing and not paused:
		var playback_position = track.get_playback_position()
		var current_time = playback_position

		# Calculate the new beat based on the current playback position
		var new_beat = int(current_time / beat_interval)
		
		# If ignoring off-beats, only update on every second beat
		if ignore_off_beats:
			# Only update the beat on even beats (0, 2, 4, etc.)
			if new_beat % 2 == 0 and new_beat != current_beat:
				current_beat = new_beat
				highlight_current_row()
				check_looping()
		else:
			# Regular beat update when not ignoring off-beats
			if new_beat != current_beat:
				current_beat = new_beat
				highlight_current_row()
				check_looping()


func check_looping():
	if enable_loop.button_pressed == true:
		if current_beat == int(end_loop.text):
			current_beat = int(begin_loop.text)
			track.seek(current_beat * beat_interval)
	else:
		pass


func populate_beats():
	beat_interval = 60.0 / bpm / 4.0
	var total_beats = 64  # Arbitrary number of beats to start with, can be adjusted
	var real_total_beats = track.get_stream().get_length() / beat_interval
	total_beats = real_total_beats
	for i in range(0, total_beats):
		var beat_row = MEASURE_ROW.instantiate()
		vbox_container.add_child(beat_row)
		
		var label = beat_row.get_child(0)  # Assuming the first child is the label displaying the beat number
		label.text = str(i)

		# Apply color logic
		if i % 16 == 0:
			label.modulate = Color(1, 0, 0)  # Red color for every 16th beat
		elif i % 4 == 0:
			label.modulate = Color(1, 0.5, 0.5)  # Pink color for every 4th beat
		elif i % 2 == 0:
			label.modulate = Color(0.8, 0.8, 0.8)  # Slightly dimmer color for every other beat
		else:
			label.modulate = Color(1, 1, 1)  # Normal color for other beats

		# Apply grey scale color logic
		if i % 16 == 0:
			for child in beat_row.get_children():
				child.self_modulate = Color(1, 1, 1, 1)  # Brightest grey for every 16th beat
		elif i % 4 == 0:
			for child in beat_row.get_children():
				child.self_modulate = Color(1, 1, 1, 0.8)  # Second brightest grey for every 4th beat
		elif i % 2 == 0:
			for child in beat_row.get_children():
				child.self_modulate = Color(1, 1, 1, 0.5)  # Third brightest grey for every other beat
		else:
			for child in beat_row.get_children():
				child.self_modulate = Color(1, 1, 1, 0.3)  # Darkest grey for off beats
				if ignore_off_beats == true:
					if child is Button:
						child.disabled = true

		# Populate buttons from loaded song data
		if JSON_PATH != "":
			for note_data in song_data:
				var note_time = note_data["time"]
				if int(note_time / beat_interval) == i:
					toggle_button(beat_row, note_data["key"])

	song_slider.max_value = total_beats - 1
	total_rows = vbox_container.get_child_count()



func highlight_current_row():
	reset_highlighting()
	if ignore_off_beats == false:
		# Get the current row to highlight and enable
		var child = vbox_container.get_child(current_beat)
		child.modulate = Color(1, 0, 0, 1)
		child.enabled = true  # Enable the current row

		# Simplify scroll position calculation based on the current beat and row height
		var row_height = 24  # Assuming each row is 24 units tall
		var target_position = current_beat * row_height

		# Center the row within the view
		scroll_vertical = target_position - (size.y / 2) + (row_height / 2)
		song_slider.value = current_beat  # Update slider value to match current beat
	else:
		# When ignore_off_beats is true, highlight every 2nd beat
		if current_beat % 2 == 0:
			# Get the current row to highlight and enable
			var child = vbox_container.get_child(current_beat)
			child.modulate = Color(1, 0, 0, 1)
			child.enabled = true  # Enable the current row

			# Simplify scroll position calculation based on the current beat and row height
			var row_height = 24  # Assuming each row is 24 units tall
			var target_position = current_beat * row_height

			# Center the row within the view
			scroll_vertical = target_position - (size.y / 2) + (row_height / 2)
			song_slider.value = current_beat  # Update slider value to match current beat


func reset_highlighting():
	for i in range(vbox_child_count):
		var row = vbox_container.get_child(i)
		row.modulate = Color(1, 1, 1, 1)  # Reset the highlight
		row.enabled = false  # Disable all rows
	if current_beat >= vbox_child_count:
		playing = false
		current_beat = 0


func _on_play_track_pressed():
	playing = true
	paused = false
	
	# Calculate the starting position in the track based on the current slider value
	var beat_interval = 60.0 / bpm / 4.0
	var start_position = song_slider.value * beat_interval
	
	# Start the track from the calculated position
	track.play(start_position)
	
	# Ensure the current beat is set correctly
	current_beat = song_slider.value
	
	# Highlight the correct row
	highlight_current_row()


func _on_pause_track_pressed():
	paused = not paused
	if paused:
		track.stop()  # Pause the track
	else:
		track.play()  # Resume the track

func _on_stop_track_pressed():
	playing = false
	paused = false
	current_beat = 0
	reset_highlighting()
	scroll_vertical = 0
	song_slider.value = 0
	track.stop()

func _on_save_json_file_pressed():
	var new_song_data = []
	var beat_interval = 60.0 / bpm / 4.0
	
	for i in range(vbox_container.get_child_count()):
		var beat_row = vbox_container.get_child(i)
		
		# Start iterating from the first actual child (index 1)
		for j in range(1, beat_row.get_child_count()):
			var button = beat_row.get_child(j)
			if button is Button:
				if button.button_pressed:
					var note_time = i * beat_interval
					var note_key = ""

					# Handle regular notes
					if j == 1:
						note_key = "a"
					elif j == 2:
						note_key = "s"
					elif j == 3:
						note_key = "d"
					elif j == 4:
						note_key = "f"
					elif j == 6:
						note_key = "j"
					elif j == 7:
						note_key = "k"
					elif j == 8:
						note_key = "l"
					elif j == 9:
						note_key = ";"

					# Handle high notes
					if button.text == "High":
						if j == 1:
							note_key = "q"
						elif j == 2:
							note_key = "w"
						elif j == 3:
							note_key = "e"
						elif j == 4:
							note_key = "r"
						elif j == 6:
							note_key = "u"
						elif j == 7:
							note_key = "i"
						elif j == 8:
							note_key = "o"
						elif j == 9:
							note_key = "p"

					if note_key != "":
						new_song_data.append({"time": note_time, "key": note_key})

	# Convert new JSON data to a string
	var json_string = JSON.stringify(new_song_data)
	
	# Get the file name from the input field, or use the default name
	var file_name = default_file_name
	var save_path = "res://Songs/JSON/" + file_name + ".json"
	
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_string(json_string)
	save_file.close()
	print("Saved to", save_path)


func _on_clear_all_notes_pressed():
	for row in vbox_container.get_children():
		for grid in row.get_children():
			if grid is Button:
				grid.button_pressed = false


func _on_ignore_off_beats_toggled(toggled_on: bool):
	ignore_off_beats = toggled_on

	for i in range(vbox_container.get_child_count()):
		var beat_row = vbox_container.get_child(i)

		# Check if the row is an odd-numbered row
		if i % 2 != 0:
			for child in beat_row.get_children():
				if child is Button:
					child.disabled = toggled_on  # Disable or enable the buttons based on the toggle state

	# Update highlighting to reflect the changes
	reset_highlighting()
	highlight_current_row()



func _on_save_scene_pressed():
	_on_save_json_file_pressed()
	# Load the template scene
	var template_scene = preload("res://Songs/TemplateSong/TemplateSong.tscn")
	
	# Instance the template scene
	var scene_instance = template_scene.instantiate()
	
	# Set the variables on the template scene

	scene_instance.bpm = bpm
	scene_instance.offset = 0.0  # You can change this to another value if needed
	scene_instance.JSON_PATH = "res://Songs/JSON/" + default_file_name + ".json"
	scene_instance.song_to_load = track.get_stream()  # Set the song's audio stream to the one currently loaded
	scene_instance.guitar_enabled = guitar_enabled
	# Save the modified scene to the specified path
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(scene_instance)
	
	if result == OK:
		# Get the file name from the input field, or use the default name
		var file_name = default_file_name
		var save_path = "res://Songs/" + file_name + ".tscn"
		recently_saved_song = save_path
		var save_result = ResourceSaver.save(packed_scene, save_path)
		if save_result == OK:
			print("Scene saved to: ", save_path)
		else:
			print("Failed to save scene")
	else:
		print("Failed to pack scene")



func _on_play_song_pressed():
	var sub_viewport = $"../SubViewportContainer/SubViewport"
	sub_viewport.get_child(0).queue_free()
	var menuscene = preload("res://Scenes/Menu/Menu.tscn").instantiate()
	$"../SubViewportContainer/SubViewport".add_child(menuscene)


func _on_enable_guitar_toggled(toggled_on):
	if toggled_on == true:
		guitar_enabled = true
