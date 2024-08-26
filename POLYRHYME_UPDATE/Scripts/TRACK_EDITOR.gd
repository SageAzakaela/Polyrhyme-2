extends ScrollContainer

@onready var v_box_container = $VBoxContainer
const TRACK = preload("res://Scenes/Track.tscn")
@export var tracks : Array[Track] = []

func _ready():
	for track in tracks:
		var TRACK_TO_LOAD = TRACK.instantiate()
		v_box_container.add_child(TRACK_TO_LOAD)
		TRACK_TO_LOAD.editable_track = track
		TRACK_TO_LOAD.text = track.Name
