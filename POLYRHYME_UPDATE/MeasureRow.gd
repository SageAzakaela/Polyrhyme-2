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

func _process(_delta):
	if enabled:
		if Input.is_action_just_pressed("a") or Input.is_action_just_pressed("q"):
			a.button_pressed = !a.button_pressed
			a.text = "High" if Input.is_action_just_pressed("q") else ""

		elif Input.is_action_just_pressed("s") or Input.is_action_just_pressed("w"):
			s.button_pressed = !s.button_pressed
			s.text = "High" if Input.is_action_just_pressed("w") else ""

		elif Input.is_action_just_pressed("d") or Input.is_action_just_pressed("e"):
			d.button_pressed = !d.button_pressed
			d.text = "High" if Input.is_action_just_pressed("e") else ""

		elif Input.is_action_just_pressed("f") or Input.is_action_just_pressed("r"):
			f.button_pressed = !f.button_pressed
			f.text = "High" if Input.is_action_just_pressed("r") else ""

		elif Input.is_action_just_pressed("j") or Input.is_action_just_pressed("u"):
			j.button_pressed = !j.button_pressed
			j.text = "High" if Input.is_action_just_pressed("u") else ""

		elif Input.is_action_just_pressed("k") or Input.is_action_just_pressed("i"):
			k.button_pressed = !k.button_pressed
			k.text = "High" if Input.is_action_just_pressed("i") else ""

		elif Input.is_action_just_pressed("l") or Input.is_action_just_pressed("o"):
			l.button_pressed = !l.button_pressed
			l.text = "High" if Input.is_action_just_pressed("o") else ""

		elif Input.is_action_just_pressed(";") or Input.is_action_just_pressed("p"):
			_semicolon.button_pressed = !_semicolon.button_pressed
			_semicolon.text = "High" if Input.is_action_just_pressed("p") else ""

	# Check button states outside the 'enabled' block to reset text when buttons are not pressed
	if not a.button_pressed:
		a.text = ""
	if not s.button_pressed:
		s.text = ""
	if not d.button_pressed:
		d.text = ""
	if not f.button_pressed:
		f.text = ""
	if not j.button_pressed:
		j.text = ""
	if not k.button_pressed:
		k.text = ""
	if not l.button_pressed:
		l.text = ""
	if not _semicolon.button_pressed:
		_semicolon.text = ""

	
