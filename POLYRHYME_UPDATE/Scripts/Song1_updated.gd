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

@export var bpm: float = 120.0  # BPM of the song
@export var offset: float = 2.0
@export var JSON_PATH: String = ""

const DIAMOND_FULL = preload("res://Textures/Diamond2.png")
const DIAMOND_EMPTY = preload("res://Textures/Diamond.png")
const NOTE = preload("res://Scenes/note.tscn")

var song_data: Array = []
var note_spawn_index: int = 0
var song_started: bool = false

# Calculate the interval for a 16th note
var sixteenth_note_interval: float = 0.0

func _ready():
	sixteenth_note_interval = 60.0 / bpm / 4.0
	
	var song = FileAccess.open(JSON_PATH, FileAccess.READ)
	var obj = JSON.new()
	var json_str = song.get_as_text()
	obj.parse(json_str)
	song_data = obj.get_data()

	spawn_notes()
	spawn_notes()
	spawn_notes()
	spawn_notes()
	spawn_notes()
	spawn_notes()
	spawn_notes()
	spawn_notes()
	$Music.play()
	song_started = true

func _process(_delta):
	if song_started and note_spawn_index < song_data.size():
		spawn_notes()
		spawn_notes()
		spawn_notes()
		spawn_notes()

	change_diamond_texture()

func change_diamond_texture():
	for i in range(8):
		var key = ["a", "s", "d", "f", "j", "k", "l", ";"][i]
		var diamond = [diamond_1, diamond_2, diamond_3, diamond_4, diamond_5, diamond_6, diamond_7, diamond_8][i]
		if Input.is_action_pressed(key):
			diamond.texture = DIAMOND_FULL
		else:
			diamond.texture = DIAMOND_EMPTY

func spawn_notes():
	var current_time = $Music.get_playback_position()
	while note_spawn_index < song_data.size():
		var note_data = song_data[note_spawn_index]
		var note_time = note_data["time"]
		var note_key = note_data["key"]

		var adjusted_note_time = note_time - offset

		# Quantize note spawning to 16th note intervals
		var quantized_time = round(adjusted_note_time / sixteenth_note_interval) * sixteenth_note_interval

		if current_time >= quantized_time:
			var note_instance = NOTE.instantiate()
			
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
				_:
					print("Unknown note key:", note_key)
			
			# Set the note's data and target after it's added to the scene
			note_instance.set_note_data(note_data)
			note_instance.target_y = diamond_1.global_position.y
			note_spawn_index += 1
		else:
			break

func _on_music_finished():
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn")
