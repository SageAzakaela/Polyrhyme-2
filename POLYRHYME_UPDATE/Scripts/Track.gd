extends Button

@onready var chart_container = $"../../../ChartContainer"

@export var editable_track: Track


func _on_pressed():
	chart_container.bpm = editable_track.BPM
	chart_container.default_file_name = editable_track.Name
	chart_container.JSON_PATH = editable_track.JSON_path
	chart_container.song_to_play = editable_track.MusicFile
	chart_container._ready()
