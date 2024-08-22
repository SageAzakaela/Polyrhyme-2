extends ScrollContainer

@export var bpm: float = 120.0  # BPM of the song
@export var JSON_PATH: String = ""

const MEASURE_ROW:  = preload("res://measure_row.tscn")
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
	load_json()
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
				var target_position = vbox_container.get_minimum_size().y - target_row.position.y - size.y
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
	var total_beats = ceil(song_data[-1]["time"] / beat_interval)
	
	for i in range(0, total_beats):  # Loop backwards
		if i % 4 == 0 and i > 0:
			var grey_panel = GREY_PANEL.instantiate()
			vbox_container.add_child(grey_panel)

		if i % 16 == 0 and i > 0:
			var pink_panel = PINK_PANEL.instantiate()
			vbox_container.add_child(pink_panel)

		var beat_row = MEASURE_ROW.instantiate()
		vbox_container.add_child(beat_row)
		populate_beat(beat_row, i * beat_interval, beat_interval)

func populate_beat(beat_row, beat_start_time, interval):
	for i in range(beat_row.get_child_count()):
		var button = beat_row.get_child(i)
		button.button_pressed = false

	for note_data in song_data:
		var note_time = note_data["time"]
		var note_key = note_data["key"]
		
		if note_time >= beat_start_time and note_time < (beat_start_time + interval):
			toggle_button(beat_row, note_key)

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
		button.button_pressed = true

func highlight_current_row():
	reset_highlighting()
	if current_beat < vbox_container.get_child_count():
		var current_row = vbox_container.get_child(current_beat)
		current_row.modulate = Color(0.5, 0.5, 1, 1)  # Change to a noticeable color (blue tint)
		if current_row.get_child_count() != 0:
			current_row.get_child(0).grab_focus()


func reset_highlighting():
	for i in range(vbox_container.get_child_count()):
		var row = vbox_container.get_child(i)
		row.modulate = Color(1, 1, 1, 1)  # Reset row highlighting

func get_visible_row(beat_index):
	# Skip grey and pink panels
	var row_index = 0
	for i in range(vbox_container.get_child_count()):
		var row = vbox_container.get_child(i)
		# Check if the row is an instance of MEASURE_ROW (replace VBoxContainer with the correct type)
		if row is GridContainer:  # Assuming MEASURE_ROW is of type VBoxContainer
			if row_index == beat_index:
				return row
			row_index += 1
	return null


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
	scroll_vertical = vbox_container.get_minimum_size().y  # Scroll back to the bottom
	track.stop()

func _on_save_json_file_pressed():
	var new_song_data = []
	var beat_interval = 60.0 / bpm / 4.0
	
	for i in range(vbox_container.get_child_count()):
		var beat_row = vbox_container.get_child(i)
		
		for j in range(beat_row.get_child_count()):
			var button = beat_row.get_child(j)
			if button.button_pressed:
				var note_time = i * beat_interval
				var note_key = ""
				
				match j:
					0: note_key = "a"
					1: note_key = "s"
					2: note_key = "d"
					3: note_key = "f"
					4: note_key = "j"
					5: note_key = "k"
					6: note_key = "l"
					7: note_key = ";"
				
				new_song_data.append({"time": note_time, "key": note_key})

	# Convert new JSON data to a string
	var json_string = JSON.stringify(new_song_data)
	var save_file = FileAccess.open(JSON_PATH, FileAccess.WRITE)
	save_file.store_string(json_string)
	save_file.close()
	print("Saved to", JSON_PATH)

