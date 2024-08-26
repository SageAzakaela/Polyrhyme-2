extends Node2D

@onready var spawner_1 = $Spawner1
@onready var spawner_2 = $Spawner2
@onready var spawner_3 = $Spawner3
@onready var spawner_4 = $Spawner4
@onready var spawner_5 = $Spawner5
@onready var spawner_6 = $Spawner6
@onready var spawner_7 = $Spawner7
@onready var spawner_8 = $Spawner8

@onready var diamond_1 = $Diamond1
@onready var diamond_2 = $Diamond2
@onready var diamond_3 = $Diamond3
@onready var diamond_4 = $Diamond4
@onready var diamond_5 = $Diamond5
@onready var diamond_6 = $Diamond6
@onready var diamond_7 = $Diamond7
@onready var diamond_8 = $Diamond8
@onready var music = $Music

@export var bpm: float = 120.0  # BPM of the song
@export var offset: float = 0.0
@export var JSON_PATH: String = ""
@export var song_to_load: AudioStream
@export var guitar_enabled: bool = false
@export var guitar_pitch_adjustment: float = 1.0
const DIAMOND_FULL = preload("res://Textures/Diamond2.png")
const DIAMOND_EMPTY = preload("res://Textures/Diamond.png")
const NOTE = preload("res://Scenes/note.tscn")
const HIGH_NOTE = preload("res://Scenes/high_note.tscn")
var song_data: Array = []
var note_spawn_index: int = 0
var song_started: bool = false
var start_time_ms: int = 0  # Store the time when the scene starts

# Calculate the interval for a 16th note and 4 beats (1 bar)
var sixteenth_note_interval: float = 0.0
var bar_delay_ms: float = 0.0  # Delay for 1 bar before starting the song in milliseconds
var beat_delay: float = 0.0  # 4 beats delay for note spawning

func _ready():
	if guitar_enabled == true:
		var guitar_player = preload("res://Scenes/guitar_player.tscn").instantiate()
		add_child(guitar_player)
		for child in guitar_player.get_children():
			child.pitch_scale = guitar_pitch_adjustment
	
	$Music.stream = song_to_load
	sixteenth_note_interval = 60.0 / bpm / 4.0
	bar_delay_ms = (60.0 / bpm * 4.0) * 1000.0  # Delay for 1 bar in milliseconds
	beat_delay = 60.0 / bpm * 4.0  # 4 beats delay before note should hit
	## For when we export, comment out the next line
	var song = FileAccess.open(JSON_PATH, FileAccess.READ)
	#var song = ResourceLoader.load(JSON_PATH)
	var obj = JSON.new()
	var json_str = song.get_as_text()
	obj.parse(json_str)
	song_data = obj.get_data()
	Score.number_of_notes_in_song = song_data.size()
	print("Number Of Notes In Song:", Score.number_of_notes_in_song)
	# Store the time when the scene is ready
	start_time_ms = Time.get_ticks_msec()

func _process(_delta):
	if not song_started:
		var current_time_ms = Time.get_ticks_msec()
		if current_time_ms - start_time_ms >= bar_delay_ms:
			$Music.play()
			song_started = true
	elif song_started and note_spawn_index < song_data.size():
		spawn_notes()

	change_diamond_texture()

func change_diamond_texture():
	var keys = ["a", "s", "d", "f", "j", "k", "l", ";", "q", "w", "e", "r", "u", "i", "o", "p"]
	var diamonds = [diamond_1, diamond_2, diamond_3, diamond_4, diamond_5, diamond_6, diamond_7, diamond_8]
	
	# Iterate over the first 8 keys and diamonds
	for i in range(8):
		var key = keys[i]
		var diamond = diamonds[i]
		if Input.is_action_pressed(key) or Input.is_action_pressed(keys[i + 8]):
			diamond.texture = DIAMOND_FULL
		else:
			diamond.texture = DIAMOND_EMPTY


func spawn_notes():
	var current_time = $Music.get_playback_position()
	while note_spawn_index < song_data.size():
		var note_data = song_data[note_spawn_index]
		var note_time = note_data["time"]
		var note_key = note_data["key"]

		var adjusted_note_time = note_time - beat_delay

		# Quantize note spawning to 16th note intervals
		var quantized_time = round(adjusted_note_time / sixteenth_note_interval) * sixteenth_note_interval

		if current_time >= quantized_time:
			var note_instance = null
			var high_note_instance = null
			
			# Instantiate based on note type
			match note_key:
				"a", "s", "d", "f", "j", "k", "l", ";":
					note_instance = NOTE.instantiate()
				"q", "w", "e", "r", "u", "i", "o", "p":
					high_note_instance = HIGH_NOTE.instantiate()
				_:
					print("Unknown note key:", note_key)
					note_spawn_index += 1
					continue
			
			# Add to the correct spawner based on note key
			if note_instance:
				match note_key:
					"a":
						spawner_1.add_child(note_instance)
					"s":
						spawner_2.add_child(note_instance)
					"d":
						spawner_3.add_child(note_instance)
					"f":
						spawner_4.add_child(note_instance)
					"j":
						spawner_5.add_child(note_instance)
					"k":
						spawner_6.add_child(note_instance)
					"l":
						spawner_7.add_child(note_instance)
					";":
						spawner_8.add_child(note_instance)
				
				# Set data for regular note
				note_instance.set_note_data(note_data)
				note_instance.target_y = diamond_1.global_position.y
				
			elif high_note_instance:
				match note_key:
					"q":
						spawner_1.add_child(high_note_instance)
					"w":
						spawner_2.add_child(high_note_instance)
					"e":
						spawner_3.add_child(high_note_instance)
					"r":
						spawner_4.add_child(high_note_instance)
					"u":
						spawner_5.add_child(high_note_instance)
					"i":
						spawner_6.add_child(high_note_instance)
					"o":
						spawner_7.add_child(high_note_instance)
					"p":
						spawner_8.add_child(high_note_instance)

				# Set data for high note
				high_note_instance.set_note_data(note_data)
				high_note_instance.target_y = diamond_1.global_position.y
				
			note_spawn_index += 1
		else:
			break


func _on_music_finished():
	Score.number_of_notes_hit = 0
	Score.multiplier = 0
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn")
