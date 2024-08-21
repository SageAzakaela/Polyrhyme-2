extends Node2D

@onready var music = $"../../Music"

var target_y = 0.0  # Y position the note is moving towards
var note_data: Dictionary = {}
var time: float = 0.0  # The time when the note should be hit
var start_y: float = -1000.0  # Initial Y position of the note
var start_time: float = 0.0  # Time at which the note starts moving
var total_time: float = 0.0  # Total time from start to hit
var early_spawn_offset: float = 0.85  # Spawn the note this many seconds earlier

func set_note_data(data: Dictionary):
	note_data = data
	time = note_data.get("time", 0.0)  # Get the time this note should be hit

	# Set the starting time earlier so the note has more time to move
	start_time = music.get_playback_position()
	start_y = global_position.y

	# Calculate the extended total time the note has to travel
	total_time = time - start_time + early_spawn_offset

	if total_time <= 0:
		#print("Note skipped because it's too late")
		queue_free()  # If total_time is too short or negative, the note is already late, so remove it.
	else:
		#print("Note will move from start_y:", start_y, "to target_y:", target_y, "over", total_time, "seconds")
		pass
	# Set the initial position (could be higher for a slower effect)
	global_position.y = start_y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_towards_target(delta)

func move_towards_target(delta):
	# Calculate the current time and remaining time before the note should be hit
	var current_time = music.get_playback_position()
	var time_elapsed = current_time - start_time

	if total_time > 0 and time_elapsed <= total_time:
		# Calculate the interpolation factor
		var progress = (time_elapsed / total_time)

		# Interpolate the Y position using lerp
		global_position.y = lerp(start_y, target_y -24, progress)
		#print("Note moving. Current position:", global_position.y, "Target position:", target_y)
	else:
		# If the note has passed the target time or is late, remove it
		#print("Note removed at position:", global_position.y)
		Score.score -= 10
		queue_free()

	# If the note reaches or passes the target Y position, remove it
	if global_position.y >= target_y + 120:
		#print("Note reached the target and is being removed")
		$CPUParticles2D.emitting = false

func _on_cpu_particles_2d_finished():
	queue_free()
	
