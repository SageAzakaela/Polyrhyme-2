extends GridContainer

@onready var a = $A
@onready var s = $S
@onready var d = $D
@onready var f = $F
@onready var j = $J
@onready var k = $K
@onready var l = $L
@onready var _semicolon = $_

var enabled: bool = false

func _physics_process(_delta):
	if enabled:
		var keys_pressed = []

		# Check all keys at the same time
		for key in ["a", "s", "d", "f", "j", "k", "l", ";", "q", "w", "e", "r", "u", "i", "o", "p"]:
			if Input.is_action_just_pressed(key):
				keys_pressed.append(key)

		# Process all pressed keys in one frame
		for key in keys_pressed:
			toggle_button(key)

func toggle_button(note_key):
	var button = null
	match note_key:
		"a", "q": button = a
		"s", "w": button = s
		"d", "e": button = d
		"f", "r": button = f
		"j", "u": button = j
		"k", "i": button = k
		"l", "o": button = l
		";", "p": button = _semicolon

	if button:
		button.button_pressed = !button.button_pressed
		button.text = "High" if note_key in ["q", "w", "e", "r", "u", "i", "o", "p"] else ""
