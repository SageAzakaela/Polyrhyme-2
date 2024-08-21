extends Sprite2D

@export var key : String = ""
var has_note : bool = false
var note: Node
@export var music: AudioStreamPlayer  # Reference to the Music node

func _process(_delta):
	get_input()

func get_input():
	if has_note and note != null:
		if Input.is_action_just_pressed(key):
			if note_in_hitbox():
				Score.score += 10
				print("Hit! Current Score:", Score.score)
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

func _on_area_2d_area_exited(area):
	if area == note:
		has_note = false
		note = null


func queue_free_note():
	if note != null:
		note.get_parent().queue_free()  # Remove the note after it's been successfully hit
		note = null
