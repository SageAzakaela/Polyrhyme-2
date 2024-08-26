extends Sprite2D

@export var key : String = ""
@export var high_key: String = ""
var has_note : bool = false
var note: Node
var has_high_note : bool = false
@export var music: AudioStreamPlayer  # Reference to the Music node

func _process(_delta):
	get_input()

func get_input():
	if has_note and note != null:
		if Input.is_action_just_pressed(key):
			if note_in_hitbox():
				Score.multiplier += 0.1
				Score.score += 10 + (10 * Score.multiplier)
				Score.number_of_notes_hit += 1
				#print("Hit! Current Score:", Score.score)
				queue_free_note()
				$GPUParticles2D.emitting = false
				$GPUParticles2D.emitting = true
	if has_high_note and note != null:
		if Input.is_action_just_pressed(high_key):
			if note_in_hitbox():
				Score.multiplier += 0.1
				Score.score += 15 + (10 * Score.multiplier)
				Score.number_of_notes_hit += 1
				#print("Hit! Current Score:", Score.score)
				queue_free_note()
				$GPUParticles2D.emitting = false
				$GPUParticles2D.emitting = true

func note_in_hitbox() -> bool:
	# Check if note is within the hitbox area (this could be more sophisticated if necessary)
	return true  # Assuming note is within hitbox; you can refine this check

func _on_area_2d_area_entered(area):
	if area.is_in_group("note"):
		has_note = true
		note = area  # Reference the note that entered the area
	if area.is_in_group("high_note"):
		has_high_note = true
		note = area  # Reference the note that entered the area

func _on_area_2d_area_exited(area):
	if area == note:
		has_note = false
		has_high_note = false
		note = null


func queue_free_note():
	if note != null:
		note.get_parent().queue_free()  # Remove the note after it's been successfully hit
		note = null
