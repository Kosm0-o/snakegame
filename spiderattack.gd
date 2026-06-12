extends Node2D

var targetpos : Vector2i
var dir : Vector2
var speed : float = 500.0

func _process(delta: float) -> void:
	global_position += dir * speed * delta
	scale.x = lerpf(scale.x, 1.0, 3 * delta)
	var gridpos = Vector2i(global_position / 20)
	if gridpos.distance_squared_to(targetpos) <= 1:
		_spawn_web()

func _spawn_web():
	global.sendingweb = false
	global.webcount += 1
	var web = preload("res://spiderweb.tscn").instantiate()
	web.name = "spiderweb" + str(global.webcount)
	web.global_position = targetpos * 20 + global.offset
	get_tree().current_scene.call_deferred("add_child", web)
	call_deferred("queue_free")
