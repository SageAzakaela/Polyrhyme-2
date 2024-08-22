extends Label



func _process(delta):
	text = "Multiplier: " + str(Score.multiplier * 10) + "X\nScore: " + str(Score.score)
