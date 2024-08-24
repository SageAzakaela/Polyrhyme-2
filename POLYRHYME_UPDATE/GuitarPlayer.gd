extends Node

@onready var _a = $_A
@onready var _s = $_S
@onready var _d = $_D
@onready var _f = $_F
@onready var _j = $_J
@onready var _k = $_K
@onready var _l = $_L
@onready var _colon = $_colon
@onready var _q = $_Q
@onready var _w = $_W
@onready var _e = $_E
@onready var _r = $_R
@onready var _u = $_U
@onready var _i = $_I
@onready var _o = $_O
@onready var _p = $_P

func _process(_delta):
	if Input.is_action_just_pressed("a"):
		_a.play()
	if Input.is_action_just_pressed("s"):
		_s.play()
	if Input.is_action_just_pressed("d"):
		_d.play()
	if Input.is_action_just_pressed("f"):
		_f.play()
	if Input.is_action_just_pressed("j"):
		_j.play()
	if Input.is_action_just_pressed("k"):
		_k.play()
	if Input.is_action_just_pressed("l"):
		_l.play()
	if Input.is_action_just_pressed(";"):
		_colon.play()

	if Input.is_action_just_pressed("Q"):
		_q.play()
	if Input.is_action_just_pressed("W"):
		_w.play()
	if Input.is_action_just_pressed("E"):
		_e.play()
	if Input.is_action_just_pressed("R"):
		_r.play()
	if Input.is_action_just_pressed("U"):
		_u.play()
	if Input.is_action_just_pressed("I"):
		_i.play()
	if Input.is_action_just_pressed("O"):
		_o.play()
	if Input.is_action_just_pressed("P"):
		_p.play()


	if Input.is_action_just_released("a"):
		_a.stream_paused = true
	if Input.is_action_just_released("s"):
		_s.stream_paused = true
	if Input.is_action_just_released("d"):
		_d.stream_paused = true
	if Input.is_action_just_released("f"):
		_f.stream_paused = true
	if Input.is_action_just_released("j"):
		_j.stream_paused = true
	if Input.is_action_just_released("k"):
		_k.stream_paused = true
	if Input.is_action_just_released("l"):
		_l.stream_paused = true
	if Input.is_action_just_released(";"):
		_colon.stream_paused = true


	if Input.is_action_just_released("Q"):
		_q.stream_paused = true
	if Input.is_action_just_released("W"):
		_w.stream_paused = true
	if Input.is_action_just_released("E"):
		_e.stream_paused = true
	if Input.is_action_just_released("R"):
		_r.stream_paused = true
	if Input.is_action_just_released("U"):
		_u.stream_paused = true
	if Input.is_action_just_released("I"):
		_i.stream_paused = true
	if Input.is_action_just_released("O"):
		_o.stream_paused = true
	if Input.is_action_just_released("P"):
		_p.stream_paused = true
