extends HSlider
@onready var guitar_player = $"../EnableGuitar/GuitarPlayer"



func _on_value_changed(value):
	for child in guitar_player.get_children():
		child.pitch_scale = value
