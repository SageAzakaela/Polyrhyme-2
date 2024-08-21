extends Node2D

@onready var spawner_1 = $Spawner1
@onready var spawner_2 = $Spawner2
@onready var spawner_3 = $Spawner3
@onready var spawner_4 = $Spawner4

@onready var diamond_1 = $Diamond1
@onready var diamond_2 = $Diamond2
@onready var diamond_3 = $Diamond3
@onready var diamond_4 = $Diamond4

@export var bpm: float = 120.0  # BPM of the song
@export var offset: float = .8

@export var JSON_PATH: String = ""

const DIAMOND_FULL = preload("res://Textures/Diamond2.png")
const DIAMOND_EMPTY = preload("res://Textures/Diamond.png")
const NOTE = preload("res://Scenes/note.tscn")

var song_data: Array = []
var note_spawn_index: int = 0
var song_started: bool = false
var time_per_16th_note: float = 0.0

func _ready():
	var song = FileAccess.open(JSON_PATH, FileAccess.READ)
	var obj = JSON.new()
	var json_str = song.get_as_text()
	obj.parse(json_str)
	song_data = obj.get_data()

	time_per_16th_note = 60.0 / (bpm * 4)  # Calculate the duration of one 16th note

	$Music.play()
	song_started = true

func _process(_delta):
	if song_started and note_spawn_index < song_data.size():
		spawn_notes()

	change_diamond_texture()

func change_diamond_texture():
	if Input.is_action_pressed("a"):
		diamond_1.texture = DIAMOND_FULL
	else:
		diamond_1.texture = DIAMOND_EMPTY
	if Input.is_action_pressed("s"):
		diamond_2.texture = DIAMOND_FULL
	else:
		diamond_2.texture = DIAMOND_EMPTY
	if Input.is_action_pressed("k"):
		diamond_3.texture = DIAMOND_FULL
	else:
		diamond_3.texture = DIAMOND_EMPTY
	if Input.is_action_pressed("l"):
		diamond_4.texture = DIAMOND_FULL
	else:
		diamond_4.texture = DIAMOND_EMPTY

func spawn_notes():
	var current_time = $Music.get_playback_position()
	while note_spawn_index < song_data.size():
		var note_data = song_data[note_spawn_index]
		var note_time = note_data["time"]
		var note_key = note_data["key"]

		var adjusted_note_time = note_time - offset

		if current_time >= adjusted_note_time:
			var note_instance = NOTE.instantiate()
			
			match note_key:
				"a":
					spawner_1.add_child(note_instance)
				"s":
					spawner_2.add_child(note_instance)
				"k":
					spawner_3.add_child(note_instance)
				"l":
					spawner_4.add_child(note_instance)
				_:
					print("Unknown note key:", note_key)
			
			# Set the note's data and target after it's added to the scene
			note_instance.set_note_data(note_data)
			note_instance.target_y = diamond_1.global_position.y
			note_spawn_index += 1
		else:
			break
