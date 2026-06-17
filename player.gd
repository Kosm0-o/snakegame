extends Node2D
class_name Player


var snake : Array[Vector2i] = [
	Vector2i(0, 0)
]

var dir : Vector2i = Vector2i.RIGHT
var newdir : bool = false
var prevdir : Vector2i = dir
var moveframenum : int = 10
var moveframemod : float = 1.0
var frames : int = moveframenum

var abilitycds : Dictionary = {
	"ability1": 15.0,
	"ability2": 10.0
}

var abilitytimers : Dictionary = {
	"ability1": 0.0,
	"ability2": 0.0
}

#spider web attack
var spiderwebtime : float = 1.6
var spiderwebtimer : float = 0.0



func _ready() -> void:
	global.player = self
	$segments/root/itemdetector.area_entered.connect(_handle_item)
	$segments/root/segmentdetector.area_entered.connect(_die)
	$segments/root/bossattackdetector.area_entered.connect(_handle_attack)
	$ui/ability1/ProgressBar.max_value = abilitycds.ability1

func _process(delta: float) -> void:
	$ui/ability1/ProgressBar.value = abilitytimers.ability1
	$ui/ability1.modulate.a = 1.0 if abilitytimers.ability1 >= abilitycds.ability1 else 0.39
	if not newdir:
		dir = Vector2i(Input.get_vector("left", "right", "up", "down"))
	if dir != Vector2i.ZERO:
		newdir = true
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
		newdir = false
	
	for timer in abilitytimers:
		if abilitytimers[timer] < abilitycds[timer]:
			abilitytimers[timer] += delta
	
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
	$ui/slow.visible = spiderwebtimer > 0.0
	$segments/root/angersymbol.scale = lerp($segments/root/angersymbol.scale, Vector2.ONE * 0.65, 7 * delta)

func angry():
	$segments/root/angersymbol.visible = true
	for i in range(4):
		$segments/root/angersymbol.scale = Vector2.ONE * 2.5
		while $segments/root/angersymbol.scale.x > 1.0:
			await get_tree().process_frame
	$segments/root/angersymbol.visible = false

func _add_segment():
	var additive = preload("res://additive.tscn").instantiate()
	$segments.call_deferred("add_child", additive)
	var taildir = (snake.back() - snake[-2]) if len(snake) > 1 else -dir
	var nexttail = snake.back() + taildir
	snake.push_back(nexttail)
	additive.position = nexttail * global.tilesize

func _remove_segment():
	if len(snake) <= 1:
		_die(Area2D.new())
		return
	var seg = $segments.get_child(-1)
	seg.queue_free()
	snake.pop_back()

func tongue_tween():
	$segments/root/tongue.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	var rtween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($segments/root/tongue, "position:x", 10.0, 0.4).set_ease(Tween.EASE_IN)
	$hiss.play(1.0)
	for i in range(25):
		rtween.tween_property($segments/root/tongue, "rotation_degrees", randf_range(-20, 20), 0.05).set_ease(Tween.EASE_IN)
	tween.tween_property($segments/root/tongue, "position:x", 0.0, 0.7).set_ease(Tween.EASE_OUT).set_delay(0.7)
	await tween.finished
	$segments/root/tongue.visible = false

func _handle_attack(area : Area2D):
	var atk = area.get_parent()
	var atkname = str(atk.name)
	if "spiderweb" in atkname:
		global.effectmodulate.color = Color("#008ad5")
		spiderwebtimer += spiderwebtime
		moveframemod = 0.45
		atk.queue_free()
	elif "toxicpuddle" in atkname:
		global.effectmodulate.color = Color("#39ff34")
		_remove_segment()
		atk.queue_free()
	angry()

func _handle_item(area : Area2D):
	var item = area.get_parent()
	item.get_parent().spawn_item()
	spawn_fireball(item.global_position)
	item.queue_free()
	_add_segment()
	tongue_tween()

func spawn_fireball(pos : Vector2):
	var fireball = preload("res://fireball.tscn").instantiate()
	get_tree().current_scene.call_deferred("add_child", fireball)
	fireball.global_position = pos
	fireball.dir = pos.direction_to(global.currentboss.global_position)
	fireball.rotation = fireball.dir.angle()
	fireball.dmg = 1

func lightning_zap():
	var lightning = preload("res://lightningzap.tscn").instantiate()
	get_tree().current_scene.call_deferred("add_child", lightning)
	lightning.global_position = snake.front() * global.tilesize + global.offset
	for i in range(3):
		_remove_segment()
		await get_tree().process_frame
		await get_tree().process_frame

func _die(area : Area2D):
	global.endscreen(false)
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ability1") and abilitytimers.ability1 >= abilitycds.ability1:
		$lightning.play(2.75)
		lightning_zap()
		abilitytimers.ability1 = 0
