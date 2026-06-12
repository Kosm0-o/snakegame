extends Node2D
class_name Player


var snake : Array[Vector2i] = [
	Vector2i(0, 0)
]

var dir : Vector2i = Vector2i.RIGHT
var prevdir : Vector2i = dir
var moveframenum : int = 10
var moveframemod : float = 1.0
var frames : int = moveframenum

#spider web attack
var spiderwebtime : float = 0.8
var spiderwebtimer : float = 0.0

func _ready() -> void:
	global.player = self
	$segments/root/itemdetector.area_entered.connect(_add_segment)
	$segments/root/segmentdetector.area_entered.connect(_die)
	$segments/root/bossattackdetector.area_entered.connect(_handle_attack)

func _process(delta: float) -> void:
	dir = Vector2i(Input.get_vector("left", "right", "up", "down"))
	if not Vector2(prevdir).dot(Vector2(dir)) == -1:
		if prevdir != dir and dir == Vector2i.ZERO:
			dir = prevdir
		else:
			prevdir = dir
	else:
		dir = prevdir
		
	frames -= 1
	if frames <= 0:
		move_snake()
		frames = int(moveframenum / moveframemod)
	
	if spiderwebtimer > 0.0:
		spiderwebtimer -= delta
	elif spiderwebtimer <= 0.0 and moveframemod != 1.0:
		moveframemod = 1.0
	
	handle_fx(delta)

func move_snake():
	var nexthead = snake.front() + dir
	snake.push_front(nexthead)
	snake.pop_back()
	for i in len(snake):
		$segments.get_children()[i].position = snake[i] * global.tilesize
	$segments/root.rotation = Vector2(prevdir).angle()

func handle_fx(delta):
	$effects/slow.visible = spiderwebtimer > 0.0
	$segments/root/angersymbol.scale = lerp($segments/root/angersymbol.scale, Vector2.ONE * 0.65, 3 * delta)

func angry():
	$segments/root/angersymbol.visible = true
	for i in range(4):
		$segments/root/angersymbol.scale = Vector2.ONE * 2.5
		while $segments/root/angersymbol.scale.x > 1.0:
			await get_tree().process_frame
	$segments/root/angersymbol.visible = false

func _add_segment(area : Area2D):
	var item = area.get_parent()
	item.queue_free()
	item.get_parent().spawn_item()
	var additive = preload("res://additive.tscn").instantiate()
	$segments.call_deferred("add_child", additive)
	var taildir = (snake.back() - snake[-2]) if len(snake) > 1 else -dir
	var nexttail = snake.back() + taildir
	snake.push_back(nexttail)
	additive.position = nexttail * global.tilesize

func _handle_attack(area : Area2D):
	var atk = area.get_parent()
	var atkname = str(atk.name)
	if "spiderweb" in atkname:
		global.effectmodulate.color = Color("#008ad5")
		spiderwebtimer += spiderwebtime
		moveframemod = 0.45
		atk.queue_free()
	angry()

func _die(area : Area2D):
	get_tree().quit()
