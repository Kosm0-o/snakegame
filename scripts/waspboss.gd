extends Node2D

@export var markers : Node2D

var attacks : Array = ["dash", "stingerspray", "triplebite", "buzzbomb"]
var start : bool = false

var maxhp : int = 64
var hp : int = maxhp
var dead : bool = false

var attacking : bool = false # for bugs/glitches
var stunned : bool = false
var stuntime : float = 0.0

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
	modulate = lerp(modulate, Color(1.0,1.0,1.0,0.7), 3 * delta)
	if stuntime > 0.0:
		stunned = true
		stuntime -= delta
	else:
		stunned = false
	
	if start and not $attackplayer.is_playing() and not attacking and not stunned:
		attacking = true
		var atk = attacks.pick_random()
		stingerspray()#$attackplayer.play(atk)

func dash():
	hide()
	var num = randi_range(0, 3)
	var pos = markers.get_node("dash").get_child(num).global_position
	await get_tree().create_timer(0.1).timeout
	if not stunned: global_position = pos
	show()
	if not stunned:
		var rtween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		rtween.tween_property($shape, "rotation_degrees", -90 * num + 180, 0.4)
		await rtween.finished
	var dashtelegraph = preload("res://scenes/attacks/dashtelegraph.tscn").instantiate()
	add_child(dashtelegraph)
	dashtelegraph.rotation_degrees = $shape.rotation_degrees - 270.0
	var a : AnimationPlayer = dashtelegraph.get_node("anim")
	if not stunned: 
		a.play("flash")
		await a.animation_finished
	dashtelegraph.queue_free()
	$shape/hitbox.set_deferred("monitorable", true)
	if not stunned:
		var dtween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var dpos = Vector2.ZERO
		if num % 2 == 0:
			dpos.y = 750.0
		else:
			dpos.x = 1500.0
		if num < 2:
			dpos *= -1
		dtween.tween_property(self, "global_position", global_position + dpos, 0.4)
		await dtween.finished
	global_position = markers.get_node("origin").global_position
	$shape/hitbox.set_deferred("monitorable", false)
	var rtween2 = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	rtween2.tween_property($shape, "rotation_degrees", 0, 0.4)
	await rtween2.finished
	attacking = false

func stingerspray():
	var stween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var o = 64 * [1, -1].pick_random()
	stween.tween_property(self, "rotation_degrees", 180 + o, 0.4)
	await stween.finished
	await get_tree().create_timer(1.5).timeout
	var rtween = create_tween()
	rtween.tween_property(self, "rotation_degrees", 180 - o, 3.0)
	var instances = randi_range(3, 9)
	for i in range(instances):
		spawn_stinger()
		await get_tree().create_timer(3.0 / instances).timeout
	await rtween.finished

func spawn_stinger():
	var stinger = preload("res://scenes/attacks/stingerprojectile.tscn").instantiate()
	get_tree().current_scene.add_child(stinger)
	stinger.global_position = $stingerpos.global_position
	stinger.rotation_degrees = rotation_degrees - 90.0

func damage(amt : int, color : Color):
	hp -= amt
	print(hp)
	modulate = color
	if hp <= maxhp / 4:
		$attackplayer.speed_scale = 2.0
	elif hp <= maxhp / 2:
		$attackplayer.speed_scale = 1.5
		
		

func stun(time : float):
	$attackplayer.stop()
	stuntime += time


func _on_hitbox_area_entered(area: Area2D) -> void:
	global.player._remove_segment()
	global.effectmodulate.color = Color("#c70000")
