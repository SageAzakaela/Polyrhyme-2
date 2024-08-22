extends Button


@export var Song :String = "" ## The path to our Song Scene.

func _on_pressed():
	get_tree().change_scene_to_file(Song)
