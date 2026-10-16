extends Node2D

var attacks : Array[String] = ["shootwebs", "shooteggs", "spitvenom", "shootlasers"]
var start : bool = false
var lerps : Dictionary = {
	"position": true,
	"rotation": true,
	"string": true
}
var shape_lerp_vals : Dictionary = {
	"position": Vector2(1, -261),
	"rotation": 0.0,
	"timer": 0.0,
	"times": 0,
	"bool": false
}

var maxhp : int = 48
var hp : int = maxhp
var dead : bool = false

var attacking : bool = false # for bugs/glitches
var stunned : bool = false
var stuntime : float = 0.0

var divider : float = 1.0


func _ready() -> void:
	randomize()
	global.currentboss = self
	$shape/offset.position = Vector2(1, 0)
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
	modulate = lerp(modulate, Color(1.0,1.0,1.0,0.7), 3 * delta)
	$shape/offset.position = lerp($shape/offset.position, Vector2(1, 261), 3 * delta) if lerps.position else $shape/offset.position
	$shape/offset.rotation = lerpf($shape/offset.rotation, 0, 5 * delta) if lerps.rotation else $shape/offset.rotation
	$shape.position = lerp($shape.position, shape_lerp_vals.position, 3 * delta) if lerps.position else $shape.position
	var m = 5 if shape_lerp_vals.rotation == 0.0 else 20
	$shape.rotation_degrees = lerpf($shape.rotation_degrees, shape_lerp_vals.rotation, m * delta) if lerps.rotation else $shape.rotation_degrees
	$shape/webstring.points[1].y = lerpf($shape/webstring.points[1].y, 15, 3 * delta) if lerps.string else $shape/webstring.points[1].y
	if stuntime > 0.0:
		stunned = true
		stuntime -= delta
		global.sendingweb = false
	else:
		stunned = false
	if start and not $attackplayer.is_playing() and not attacking and not stunned:
		attacking = true
		var atk = attacks.pick_random()
		$attackplayer.play(atk)
		print(atk)
	
	if shape_lerp_vals.timer > 0.0:
		shape_lerp_vals.timer -= delta
		if shape_lerp_vals.timer <= 0.0:
			if shape_lerp_vals.times == 1:
				shape_lerp_vals.rotation = 0.0
				shape_lerp_vals.times = 0
				shape_lerp_vals.bool = false
			else:
				shape_lerp_vals.rotation *= -1
				shape_lerp_vals.times = 1
				shape_lerp_vals.timer = 0.5
	
	if randf() < 4 * delta and start:
		if randf() > 0.1 or shape_lerp_vals.bool:
			if randf() > 0.5:
				fang_tween()
			else:
				leg_tween()
		else: 
			shape_lerp_vals.rotation = randf_range(-7.0, 7.0)
			shape_lerp_vals.timer = 0.5
			shape_lerp_vals.bool = true

func shoot_webs():
	for i in range(int(randi_range(1, 8) * $attackplayer.speed_scale)):
		while global.sendingweb:
			await get_tree().process_frame
		shoot_web()
	attacking = false

func shoot_web():
	if dead: return
	global.sendingweb = true
	var webshot = preload("res://spiderattack.tscn").instantiate()
	webshot.global_position = global_position
	webshot.targetpos = Vector2i(randi_range(1, global.mapsize.x - 1), randi_range(1, global.mapsize.y - 1))
	webshot.dir = webshot.global_position.direction_to(Vector2(webshot.targetpos * global.tilesize))
	webshot.rotation = webshot.dir.angle()
	if not stunned: get_tree().current_scene.call_deferred("add_child", webshot)
	var mult = -1.0 if webshot.rotation < PI / 2 else 1.0
	$shape/offset.rotation = webshot.rotation * mult / 2

func shoot_eggs():
	lerps.rotation = false
	lerps.position = false
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($shape, "position:y", -50.0, 1.0 / $attackplayer.speed_scale)
	await tween.finished
	for i in range(int(randi_range(1, 5) * $attackplayer.speed_scale)):
		while global.sendingweb:
			await get_tree().process_frame
		shoot_egg()
	print("before tween")
	var tween2 = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween2.tween_property($shape, "position:y", -241.625, 1.0 / $attackplayer.speed_scale)
	print("during tween")
	await tween2.finished
	print("after tween")
	lerps.rotation = true
	lerps.position = true
	print(lerps.position)
	attacking = false

func shoot_egg():
	if dead: return
	global.sendingweb = true
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($shape/offset, "position:y", 246, 0.2)
	var eggshot = preload("res://spideregglaunch.tscn").instantiate()
	eggshot.global_position = $shape.global_position
	eggshot.global_position.y += 248
	eggshot.targetpos = Vector2i(randi_range(1, global.mapsize.x - 1), randi_range(1, global.mapsize.y - 1))
	$egg.play()
	if not stunned: get_tree().current_scene.call_deferred("add_child", eggshot)
	tween.tween_property($shape/offset, "position:y", 261, 0.2)


func spit_venom():
	if dead: return
	lerps.rotation = false
	lerps.position = false
	for i in range(randi_range(3, 5)):
		var droplet = preload("res://toxicdrop.tscn").instantiate()
		droplet.rotation_degrees = randf_range(-25.0, 25.0)
		droplet.position = $shape/offset/drops.position + Vector2(randf_range(-8.0, 8.0), 0)
		$shape/offset.call_deferred("add_child", droplet)
		await get_tree().create_timer(droplet.timer).timeout
	var f : bool = randf() > 0.5
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel(true)
	var m = 1 if not f else -1
	tween.tween_property($shape, "rotation_degrees", 45.0 * m, 0.6 / $attackplayer.speed_scale)
	var pos = Vector2(217.0, -216.0) if not f else Vector2(-224.0, -216.0)
	tween.tween_property($shape, "position", pos, 0.6 / $attackplayer.speed_scale)
	var venomtelegraph = preload("res://venomtelegraph.tscn").instantiate()
	venomtelegraph.global_position = Vector2(576.0, 0.0)
	venomtelegraph.scale.x = -1 if not f else 1
	get_tree().current_scene.call_deferred("add_child", venomtelegraph)
	await venomtelegraph.get_node("anim").animation_finished
	if dead: return
	venomtelegraph.call_deferred("queue_free")
	var venomspit = preload("res://venomspit.tscn").instantiate()
	venomspit.flipped = f
	if not stunned:
		get_tree().current_scene.call_deferred("add_child", venomspit)
		venomspit.global_position = Vector2.ZERO
		await venomspit.get_node("AnimationPlayer").animation_finished
	lerps.rotation = true
	lerps.position = true
	attacking = false

func shoot_lasers():
	$shape/offset/main/eyes.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($shape/offset/main/eyes, "modulate", Color(1.5,1.5,1.5,1.5), 0.8 / $attackplayer.speed_scale)
	await tween.finished
	var amt = 0
	for i in range(4):
		if randf() <= pow(0.65, i):
			amt += 1
	var eyes = $shape/offset/main/eyes/main.get_children()
	eyes.shuffle()
	for i in range(amt):
		shootlaser(eyes[i])
	
	

func shootlaser(eye):
	if dead: return
	var rot = randf_range(0.0, 180.0)
	var lasertelegraph = preload("res://lasertelegraph.tscn").instantiate()
	$shape/offset/main/eyes/main.call_deferred("add_child", lasertelegraph)
	lasertelegraph.position = eye.position
	lasertelegraph.rotation_degrees = rot
	lasertelegraph.get_node("anim").speed_scale = divider
	await lasertelegraph.get_node("anim").animation_finished
	lasertelegraph.get_node("anim").play("lockon")
	await lasertelegraph.get_node("anim").animation_finished
	lasertelegraph.call_deferred("queue_free")
	if dead: return
	var laser = preload("res://laserattack.tscn").instantiate()
	if not stunned: $shape/offset/main/eyes/main.call_deferred("add_child", laser)
	$laser.play()
	laser.position = eye.position
	laser.rotation_degrees = rot
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($shape/offset/main/eyes, "modulate", Color.WHITE, 0.5)
	$shape/offset/main/eyes.material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	await tween.finished
	attacking = false

func fang_tween():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	var fangs = $shape/offset/main/fangs.get_children()
	var val = randf_range(-20, 15)
	tween.tween_property(fangs[0], "rotation_degrees", val, 0.2)
	tween.parallel().tween_property(fangs[1], "rotation_degrees", val * -1, 0.2)
	tween.tween_property(fangs[0], "rotation_degrees", 0, 0.4)
	tween.parallel().tween_property(fangs[1], "rotation_degrees", 0, 0.4)
	await tween.finished

func leg_tween():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	var legs = $shape/offset/main/body/legs.get_children()
	var val = randf_range(-11.5, 11.5)
	legs.shuffle()
	tween.tween_property(legs[0], "rotation_degrees", val, 0.2)
	tween.tween_property(legs[0], "rotation_degrees", 0, 0.4)
	await tween.finished

func damage(amt : int, color : Color):
	hp -= amt
	print(hp)
	modulate = color
	if hp <= maxhp / 4:
		divider = 2.0
		$attackplayer.speed_scale = 2.0
	elif hp <= maxhp / 2:
		divider = 1.5
		$attackplayer.speed_scale = 1.5
	if hp <= 0:
		dead = true
		Engine.time_scale = 0.8
		get_tree().paused = true
		lerps.rotation = false
		lerps.position = false
		attacks = ["ready"]
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var tween2 = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($shape, "rotation", 0, 0.2)
		tween.tween_property($shape/offset, "position:y", $shape/offset.position.y - 35, 0.4)
		tween.tween_property($shape/offset, "position:y", $shape/offset.position.y + 1000, 2.5)
		tween2.tween_property(self, "rotation", rotation, 0.05).set_delay(0.4)
		for i in range(50):
			tween2.tween_property($shape/offset, "rotation_degrees", 90, 0.05).as_relative()
		await tween.finished
		global.currentboss = null
		global.endscreen(true)
		queue_free()
		
		

func stun(time : float):
	$attackplayer.stop()
	stuntime += time
