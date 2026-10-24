extends Node2D

var targetpos : Vector2i
var velocity : Vector2
var m = 1.5

func _ready() -> void:
	velocity = calc_arc_vel(position, targetpos * global.tilesize, 1.1, 1000.0)
	await get_tree().create_timer(0.2).timeout
	global.sendingweb = false

func _physics_process(delta: float) -> void:
	velocity.y += 1000.0 * delta
	position += velocity * delta
	rotation += delta * 25 * m
	m *= 0.98
	var gridpos = Vector2i(global_position / global.tilesize)
	if gridpos.distance_squared_to(targetpos) <= 2:
		_spawn_egg()

func calc_arc_vel(start : Vector2, end : Vector2, time : float, grav : float):
	var dis = end - start
	var vx = dis.x / time
	var vy = (dis.y - 0.5 * grav * time * time) / time
	return Vector2(vx, vy)

func _spawn_egg():
	global.eggcount += 1
	var egg = preload("res://scenes/attacks/minispideregg.tscn").instantiate()
	egg.name = "minispideregg" + str(global.eggcount)
	egg.global_position = targetpos * global.tilesize + global.offset
	get_tree().current_scene.call_deferred("add_child", egg)
	call_deferred("queue_free")
