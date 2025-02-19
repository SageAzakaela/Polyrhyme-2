extends HSlider



func _on_value_changed(pitch_value):
	$"../Track".pitch_scale = pitch_value
