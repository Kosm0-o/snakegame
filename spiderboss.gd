extends Node2D

var attacks : Array[String] = ["shootwebs"]
var start : bool = false

func _ready() -> void:
	randomize()
	$shape/offset.position = Vector2(37, -275.0)
	$shape/webstring.points[1].y = -150
	get_tree().paused = true
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($introtext/Label, "modulate:a", 1.0, 1.2)
	tween.tween_property($introtext/Label, "modulate:a", 0.0, 0.5).set_delay(0.6)
	await tween.finished
	get_tree().paused = false
	var tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(self, "modulate:a", 0.7, 0.7)
	$attackplayer.play("ready")
	start = true

func _process(delta: float) -> void:
	$shape/offset.position = lerp($shape/offset.position, Vector2(37, 0), 3 * delta)
	$shape/offset.rotation = lerpf($shape/offset.rotation, 0, 5 * delta)
	$shape/webstring.points[1].y = lerpf($shape/webstring.points[1].y, 25, 3 * delta)
	if start and not $attackplayer.is_playing():
		$attackplayer.play(attacks.pick_random())

func shoot_webs():
	for i in range(randi_range(1, 5)):
		while global.sendingweb:
			await get_tree().process_frame
			pass
		shoot_web()

func shoot_web():
	global.sendingweb = true
	var webshot = preload("res://spiderattack.tscn").instantiate()
	webshot.global_position = global_position
	webshot.targetpos = Vector2i(randi_range(1, global.mapsize.x - 1), randi_range(1, global.mapsize.y - 1))
	webshot.dir = webshot.global_position.direction_to(Vector2(webshot.targetpos * global.tilesize))
	webshot.rotation = webshot.dir.angle()
	get_tree().current_scene.call_deferred("add_child", webshot)
	var mult = -1.0 if webshot.rotation < PI / 2 else 1.0
	$shape/offset.rotation = webshot.rotation * mult / 2
