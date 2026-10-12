extends Node2D

var dir : Vector2 = Vector2.RIGHT
var speed : float = 900.0
var dmg : int = 1
var time : float = 0.0

func _process(delta: float) -> void:
	time += delta
	scale = (sin(0.5 * time) * 0.5 + 0.6) * Vector2.ONE
	dir = global_position.direction_to(global.currentboss.global_position)
	global_position += dir * speed * delta
	speed *= 0.99
	$shape.scale.x = lerpf($shape.scale.x, 1.0, 3 * delta)
	rotation = dir.angle()



func _on_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().damage(dmg, Color("#ff170f"))
	queue_free()
