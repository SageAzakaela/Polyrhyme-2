extends Label
var percentage = 0 
func _process(delta):
	if Score.number_of_notes_in_song > 0:
		percentage = (Score.number_of_notes_hit / float(Score.number_of_notes_in_song)) * 100
	else:
		percentage = 0  # To handle division by zero in case the song has no notes

	text = "Multiplier: " + str(round((Score.multiplier) * 10)) + "X\nPercentage: " + str(roundf(percentage)) + "%\nScore: " + str(Score.score)
