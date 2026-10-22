extends Node2D

var dir : Vector2 = Vector2.RIGHT
var speed : float = 900.0
var dmg : int = 1
var time : float = 0.0
var burn : bool = false

func _ready() -> void:
	global.boss_defeated.connect(func(time): queue_free())

func _process(delta: float) -> void:
	time += delta
	scale = (sin(0.5 * time) * 0.5 + 0.6) * Vector2.ONE
	dir = global_position.direction_to(global.currentboss.global_position)
	global_position += dir * speed * delta
	speed *= 0.99
	$shape.scale.x = lerpf($shape.scale.x, 1.0, 3 * delta)
	rotation = dir.angle()



func _on_area_2d_area_entered(area: Area2D) -> void:
	hide()
	var rand = randi_range(3, 7)
	if burn:
		for i in range(int(rand/2)):
			global.player._remove_segment()
			await get_tree().process_frame
	for i in range(rand if burn else 1):
		area.get_parent().damage(dmg, Color("#ff170f"))
		await get_tree().create_timer(0.5).timeout
	queue_free()
