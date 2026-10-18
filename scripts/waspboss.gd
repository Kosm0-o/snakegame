extends Node2D

@export var markers : Node2D

var attacks : Array = ["dash", "stingerspray", "stingerslam", "buzzbombs"]
var start : bool = false

var maxhp : int = 64
var hp : int = maxhp
var dead : bool = false

var attacking : bool = false # for bugs/glitches
var stunned : bool = false
var stuntime : float = 0.0

var time : float = 0.0
var divider : float = 1.0

func _ready() -> void:
	randomize()
	global.currentboss = self
	global_position = markers.get_node("origin").global_position
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
	time += delta
	modulate = lerp(modulate, Color(1.0,1.0,1.0,0.7), 3 * delta)
	if stuntime > 0.0:
		stunned = true
		stuntime -= delta
	else:
		stunned = false
	
	if start and not $attackplayer.is_playing() and not attacking and not stunned:
		attacking = true
		var atk = attacks.pick_random()
		$attackplayer.play(atk)
	
	for i in $shape/wings.get_children().size():
		var wing = $shape/wings.get_child(i)
		if i == 0:
			wing.rotation_degrees = -14.0 + sin(25.0 * time) * 5.0
		else:
			wing.rotation_degrees = 14.0 + sin(-25.0 * time) * 5.0

func dash():
	hide()
	var num = randi_range(0, 3)
	var pos = markers.get_node("dash").get_child(num).global_position
	await get_tree().create_timer(0.1).timeout
	if not stunned: global_position = pos
	show()
	if not stunned:
		var rtween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		rtween.tween_property($shape, "rotation_degrees", -90 * num + 180, 0.4 / divider)
		await rtween.finished
	var dashtelegraph = preload("res://scenes/attacks/dashtelegraph.tscn").instantiate()
	add_child(dashtelegraph)
	dashtelegraph.rotation_degrees = $shape.rotation_degrees - 270.0
	var a : AnimationPlayer = dashtelegraph.get_node("anim")
	a.speed_scale *= divider
	if not stunned: 
		a.play("flash")
		await a.animation_finished
	dashtelegraph.queue_free()
	$shape/hitbox.set_deferred("monitorable", true)
	$shape/hitbox.set_deferred("monitoring", true)
	if not stunned:
		var dtween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var dpos = Vector2.ZERO
		if num % 2 == 0:
			dpos.y = 750.0
		else:
			dpos.x = 1500.0
		if num < 2:
			dpos *= -1
		dtween.tween_property(self, "global_position", global_position + dpos, 0.4 / divider)
		await dtween.finished
	global_position = markers.get_node("origin").global_position
	$shape/hitbox.set_deferred("monitorable", false)
	$shape/hitbox.set_deferred("monitoring", false)
	var rtween2 = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	rtween2.tween_property($shape, "rotation_degrees", 0, 0.4 / divider)
	await rtween2.finished
	attacking = false

func stingerspray():
	if stunned:
		attacking = false
		return
	var stween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var o = 64 * [1, -1].pick_random()
	stween.tween_property(self, "rotation_degrees", 180 + o, 0.4 / divider)
	await stween.finished
	await get_tree().create_timer(1.5).timeout
	if not stunned:
		var rtween = create_tween()
		rtween.tween_property(self, "rotation_degrees", 180 - o, 3.0 / divider)
		var instances = randi_range(3, 9)
		for i in range(instances):
			if stunned: break
			var tween = create_tween().set_ease(Tween.EASE_OUT)
			var pos = global_position
			tween.tween_property(self, "global_position", global_position + global_transform.y * 50, 0.2 / divider).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(self, "global_position", pos, 0.2 / divider).set_trans(Tween.TRANS_CUBIC)
			var stinger = spawn_stinger()
			stinger.global_position = $stingerpos.global_position
			stinger.rotation_degrees = rotation_degrees - 90.0
			await get_tree().create_timer((3.0 / divider) / instances).timeout
	var rtween2 = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	rtween2.tween_property(self, "rotation_degrees", 0.0, 0.4 / divider)
	await rtween2.finished
	attacking = false

func spawn_stinger():
	var stinger = preload("res://scenes/attacks/stingerprojectile.tscn").instantiate()
	get_tree().current_scene.add_child(stinger)
	return stinger

func stinger_slam():
	if stunned:
		attacking = false
		return
	var telegraph = preload("res://scenes/attacks/stingerslamtelegraph.tscn").instantiate()
	get_tree().current_scene.add_child(telegraph)
	telegraph.global_position = global.player.snake.front() * global.tilesize + global.offset
	var t : AnimationPlayer = telegraph.get_node("anim")
	t.speed_scale *= divider
	t.play("flash")
	await t.animation_finished
	if stunned:
		attacking = false
		telegraph.queue_free()
		return
	t.play("slam")
	await t.animation_finished
	if stunned:
		attacking = false
		telegraph.queue_free()
		return
	for i in range(8):
		var stinger = spawn_stinger()
		stinger.global_position = telegraph.global_position
		stinger.rotation_degrees = (360 / 8) * i
	telegraph.queue_free()
	attacking = false

func buzzbombs():
	if stunned:
		attacking = false
		return
	var bombs : Array = []
	for i in range(int(randi_range(2, 5) * divider)):
		if stunned: break
		var pos = Vector2(randf_range(25, 1152), randf_range(25, 648))
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", pos, 0.8 / divider)
		tween.parallel().tween_property(self, "rotation", global_position.direction_to(pos).angle(), 0.8 / divider)
		await tween.finished
		if stunned: break
		var bomb = preload("res://scenes/attacks/buzzbombs.tscn").instantiate()
		get_tree().current_scene.add_child(bomb)
		bomb.global_position = global_position
		bomb.get_node("anim").speed_scale *= divider
		bomb.get_node("anim").play("blow")
		bombs.append(bomb)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", markers.get_node("origin").global_position, 0.4 / divider)
	tween.parallel().tween_property(self, "rotation_degrees", 0, 0.4)
	await tween.finished
	attacking = false
	if not stunned: await bombs.back().get_node("anim").animation_finished
	for bomb in bombs:
		if is_instance_valid(bomb):
			bomb.queue_free()

func damage(amt : int, color : Color):
	hp -= amt
	print(hp)
	modulate = color
	if hp <= maxhp / 4:
		if divider == 1.5:
			global.effectmodulate.color = Color.RED
		divider = 2.0
		$attackplayer.speed_scale = 2.0
	elif hp <= maxhp / 2:
		if divider == 1.0:
			global.effectmodulate.color = Color.RED
		divider = 1.5
		$attackplayer.speed_scale = 1.5
	if hp <= 0:
		global.boss_defeated.emit()
		dead = true
		get_tree().paused = true
		queue_free()
		
		

func stun(time : float):
	$attackplayer.stop()
	stuntime += time


func _on_hitbox_area_entered(area: Area2D) -> void:
	global.player._remove_segment()
	global.effectmodulate.color = Color("#c70000")
