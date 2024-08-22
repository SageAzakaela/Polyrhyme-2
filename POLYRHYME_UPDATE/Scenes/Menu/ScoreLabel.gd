extends Label

func _process(_delta):
	text = "score: " + str(Score.score)
