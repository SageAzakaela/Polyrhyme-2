extends CheckButton

func _ready():
	_on_toggled(false)

func _on_toggled(toggled_on):
	if toggled_on == false:
		for child in get_child(0).get_children():
			child.volume_db = -80
	else:
		for child in get_child(0).get_children():
			child.volume_db = -10
