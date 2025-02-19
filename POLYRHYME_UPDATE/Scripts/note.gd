extends Node2D

@onready var music = $"../../Music"

var target_y = 0.0 # Y position the note is moving towards
var note_data: Dictionary = {}
var time: float = 0.0  # The time when the note should be hit
var start_y: float = -1000.0  # Initial Y position of the note
var start_time: float = 0.0  # Time at which the note starts moving
var total_time: float = 0.0  # Total time from start to hit

func set_note_data(data: Dictionary):
	note_data = data
	time = note_data.get("time", 0.0)  # The beat time this note should be hit

	# Set the starting time based on the song's playback position
	start_time = music.get_playback_position()
	start_y = global_position.y

	# Calculate the total travel time of the note
	total_time = time - start_time

	# If the note is already past due, remove it
	if total_time <= 0:
		queue_free()
	else:
		global_position.y = start_y  # Ensure note starts at correct position

func _physics_process(_delta):
	move_towards_target()

func move_towards_target():
	# Get the song's playback position
	var current_time = music.get_playback_position()
	var time_elapsed = current_time - start_time  # How long since the note started moving

	if total_time > 0:
		# Ensure smooth interpolation between start_y and target_y
		var progress = clamp(time_elapsed / total_time, 0.0, 1.0)
		global_position.y = start_y + (target_y - start_y) * progress
	else:
		# If the note is late, penalize and remove it
		Score.score -= 10
		Score.multiplier = 0.1
		Score.number_of_notes_missed += 1
		queue_free()

	# If the note moves past the target, remove it
	if global_position.y >= target_y  :
		Score.multiplier = 0.1
		Score.number_of_notes_missed += 1
		queue_free()
