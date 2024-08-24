extends ScrollContainer

@export var bpm: float = 120.0  # BPM of the song
@export var default_file_name: String = "song"  # Default file name, can be overwritten by the user
@export var JSON_PATH: String = ""  # Path to load JSON file

const MEASURE_ROW = preload("res://measure_row.tscn")
const GREY_PANEL = preload("res://Scenes/GreyPanel.tscn")
const PINK_PANEL = preload("res://Scenes/PinkPanel.tscn")
@onready var track = $"../Track"  # Assuming this is an AudioStreamPlayer
@onready var vbox_container = $VboxContainer
@onready var save_json_file = $"../Save_JSON_File"
@onready var play_track = $"../PlayTrack"
@onready var pause_track = $"../PauseTrack"
@onready var stop_track = $"../StopTrack"

var song_data: Array = []
var current_beat: int = 0
var playing: bool = false
var paused: bool = false
var beat_interval: float = 0.0

func _ready():
	load_json()  # Load the song data from JSON file
	populate_beats()
	scroll_vertical = vbox_container.get_minimum_size().y  # Set the scroll bar to the bottom initially

func _process(_delta):
	if playing and not paused:
		var playback_position = track.get_playback_position()
		var current_time = playback_position

		var new_beat = int(current_time / beat_interval)
		if new_beat != current_beat:
			current_beat = new_beat
			highlight_current_row()

			# Since the beats are in reverse order, calculate the row from the end
			var total_rows = vbox_container.get_child_count()
			var reversed_index = total_rows - current_beat - 1
			
			# Scroll to the correct position (moving up since we're reversed)
			if reversed_index >= 0 and reversed_index < total_rows:
				var target_row = vbox_container.get_child(reversed_index)
				var target_position = vbox_container.get_minimum_size().y - target_row.position.y - size.y / 2
				scroll_vertical = target_position
				print("Scrolling to position: ", target_position)

		if current_beat >= vbox_container.get_child_count():
			playing = false
			current_beat = 0
			reset_highlighting()


func load_json():
	var song = FileAccess.open(JSON_PATH, FileAccess.READ)
	if song:
		var obj = JSON.new()
		var json_str = song.get_as_text()
		obj.parse(json_str)
		song_data = obj.get_data()
		song.close()
	else:
		print("Failed to load JSON")

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
			beat_row.modulate = Color(1, 1, 1)  # Brightest grey for every 16th beat
		elif i % 4 == 0:
			beat_row.modulate = Color(0.8, 0.8, 0.8)  # Second brightest grey for every 4th beat
		elif i % 2 == 0:
			beat_row.modulate = Color(0.5, 0.5, 0.5)  # Third brightest grey for every other beat
		else:
			beat_row.modulate = Color(0.3, 0.3, 0.3)  # Darkest grey for off beats

		# Populate buttons from loaded song data
		for note_data in song_data:
			var note_time = note_data["time"]
			if int(note_time / beat_interval) == i:
				toggle_button(beat_row, note_data["key"])

func toggle_button(beat_row, note_key):
	var button = null
	match note_key:
		"a": button = beat_row.a
		"s": button = beat_row.s
		"d": button = beat_row.d
		"f": button = beat_row.f
		"j": button = beat_row.j
		"k": button = beat_row.k
		"l": button = beat_row.l
		";": button = beat_row._semicolon
	if button:
		button.button_pressed = true  # Set the button as pressed

func highlight_current_row():
	reset_highlighting()
	
	# Calculate the correct beat row index by skipping grey panels
	var visible_row_count = 0
	for i in range(vbox_container.get_child_count()):
		var child = vbox_container.get_child(i)
		if child is GridContainer:
			if visible_row_count == current_beat:
				child.get_child(1).modulate = Color(1, 1, 1, 1)  # Highlight the current row
				break
			visible_row_count += 1

func reset_highlighting():
	for i in range(vbox_container.get_child_count()):
		var row = vbox_container.get_child(i)
		if row is GridContainer:  # Only reset the highlighting for measure rows
			row.get_child(1).modulate = Color(0, 0, 0, 0.0)  # Reset the row

func _on_play_track_pressed():
	playing = true
	paused = false
	track.play()

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
	track.stop()

func _on_save_json_file_pressed():
	var new_song_data = []
	var beat_interval = 60.0 / bpm / 4.0
	
	for i in range(vbox_container.get_child_count()):
		var beat_row = vbox_container.get_child(i)
		
		# Start iterating from the third child (index 2)
		for j in range(2, beat_row.get_child_count()):
			var button = beat_row.get_child(j)
			if button is Button:
				if button.button_pressed:
					var note_time = i * beat_interval
					var note_key = ""
					
					match j:
						2: note_key = "a"
						3: note_key = "s"
						4: note_key = "d"
						5: note_key = "f"
						6: note_key = "j"
						7: note_key = "k"
						8: note_key = "l"
						9: note_key = ";"
					
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
