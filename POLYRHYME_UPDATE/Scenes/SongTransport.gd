extends VSlider

@onready var song_editor = $"../ChartContainer"
@export var bpm: float = 120
func _on_drag_ended(_value_changed):
	# Calculate the time based on the beat
	var beat_interval = 60.0 / bpm / 4.0
	var target_time = value * beat_interval
	if value != max_value:
		# Seek the track to the appropriate time
		song_editor.track.seek(target_time)

		# Update the current beat and highlight the correct row
		song_editor.current_beat = value
		song_editor.highlight_current_row()
