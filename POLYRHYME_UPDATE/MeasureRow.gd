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
		if Input.is_action_just_pressed("a") or Input.is_action_just_pressed("Q"):
			a.button_pressed = !a.button_pressed
		elif Input.is_action_just_pressed("s") or Input.is_action_just_pressed("W"):
			s.button_pressed = !s.button_pressed
		elif Input.is_action_just_pressed("d") or Input.is_action_just_pressed("E"):
			d.button_pressed = !d.button_pressed
		elif Input.is_action_just_pressed("f") or Input.is_action_just_pressed("R"):
			f.button_pressed = !f.button_pressed
		elif Input.is_action_just_pressed("j") or Input.is_action_just_pressed("U"):
			j.button_pressed = !j.button_pressed
		elif Input.is_action_just_pressed("k") or Input.is_action_just_pressed("I"):
			k.button_pressed = !k.button_pressed
		elif Input.is_action_just_pressed("l") or Input.is_action_just_pressed("O"):
			l.button_pressed = !l.button_pressed
		elif Input.is_action_just_pressed(";") or Input.is_action_just_pressed("P"):
			_semicolon.button_pressed = ! _semicolon.button_pressed
