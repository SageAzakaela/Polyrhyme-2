extends Node2D

@onready var diamond_1 = $Diamond1
@onready var diamond_2 = $Diamond2
@onready var diamond_3 = $Diamond3
@onready var diamond_4 = $Diamond4
@onready var spawner_1 = $Spawner1
@onready var spawner_2 = $Spawner2
@onready var spawner_3 = $Spawner3
@onready var spawner_4 = $Spawner4

const DIAMOND_FULL = preload("res://Textures/Diamond2.png")
const DIAMOND_EMPTY = preload("res://Textures/Diamond.png")

@export var bpm: float = 120.0  # BPM of the song
var track_duration: float = 0.00
var input_record: Array = []
var input_offset_b: float = 0.00
var offset_bool: bool = false
var song_started: bool = false
var time_per_16th_note: float = 0.0

func _ready():
	track_duration = $Music.stream.get_length()
	time_per_16th_note = 60.0 / (bpm * 8)  # Calculate the duration of one 16th note

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"): 
		song_started = true
		$Music.play()
	
	change_diamond_texture()
		
	if song_started:
		record_input()

func record_input():
	if not offset_bool:
		if Input.is_action_just_pressed("a"):
			offset_bool = true
			input_offset_b = $Music.get_playback_position()
		elif Input.is_action_just_pressed("s"):
			offset_bool = true
			input_offset_b = $Music.get_playback_position()
		elif Input.is_action_just_pressed("k"):
			offset_bool = true
			input_offset_b = $Music.get_playback_position()
		elif Input.is_action_just_pressed("l"):
			offset_bool = true
			input_offset_b = $Music.get_playback_position()
	else:
		var dict = {}
		if Input.is_action_just_pressed("a"):
			dict = create_note_dict("a")
			input_record.append(dict)
		elif Input.is_action_just_pressed("s"):
			dict = create_note_dict("s")
			input_record.append(dict)
		elif Input.is_action_just_pressed("k"):
			dict = create_note_dict("k")
			input_record.append(dict)
		elif Input.is_action_just_pressed("l"):
			dict = create_note_dict("l")
			input_record.append(dict)

func create_note_dict(key: String) -> Dictionary:
	var raw_time = $Music.get_playback_position() - input_offset_b
	var snapped_time = round(raw_time / time_per_16th_note) * time_per_16th_note  # Snap to nearest 16th note
	return {
		"time": snapped_time,
		"key": key
	}

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

func _on_music_finished():
	var json_str = JSON.stringify(input_record)
	var file = FileAccess.open("res://Waiting.json", FileAccess.WRITE)
	file.store_string(json_str)
	file.close()

	var json_str2 = JSON.stringify(input_offset_b)
	var file2 = FileAccess.open("res://Waiting_offset.json", FileAccess.WRITE)
	file2.store_string(json_str2)
	file2.close()
