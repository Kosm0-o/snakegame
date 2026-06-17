extends Node2D


var start : bool = false
var dir : Vector2i = Vector2i.UP
var prevdir : Vector2i = Vector2i.UP
var moveframenum : int = 5

var frames : int = moveframenum

var snake : Array[Vector2i] = [
	Vector2i(27, 30),
	Vector2i(27, 31),
	Vector2i(27, 32),
	Vector2i(27, 33),
	Vector2i(27, 34),
	Vector2i(27, 35),
	Vector2i(27, 36),
	Vector2i(27, 37),
	Vector2i(27, 38),
	Vector2i(27, 39),
	Vector2i(27, 40),
	]
	
func _ready() -> void:
	move_snake()

func _process(delta: float) -> void:
	dir = Vector2i(Input.get_vector("left", "right", "up", "down"))
	if dir != Vector2i.ZERO: start = true
	if not start: return
	if prevdir != dir and dir == Vector2i.ZERO:
		dir = prevdir
	else:
		prevdir = dir
		
	frames -= 1
	if frames <= 0:
		if randf() < 0.01: tongue_tween()
		move_snake()
		frames = moveframenum

func move_snake():
	var nexthead = snake.front() + dir
	snake.push_front(nexthead)
	snake.pop_back()
	for i in len(snake):
		$segments.get_children()[i].position = snake[i] * global.tilesize
	$segments/root.rotation = Vector2(prevdir).angle()

func tongue_tween():
	$segments/root/tongue.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	var rtween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($segments/root/tongue, "position:x", 10.0, 0.4).set_ease(Tween.EASE_IN)
	for i in range(25):
		rtween.tween_property($segments/root/tongue, "rotation_degrees", randf_range(-20, 20), 0.05).set_ease(Tween.EASE_IN)
	tween.tween_property($segments/root/tongue, "position:x", 0.0, 0.7).set_ease(Tween.EASE_OUT).set_delay(0.7)
	await tween.finished
	$segments/root/tongue.visible = false
