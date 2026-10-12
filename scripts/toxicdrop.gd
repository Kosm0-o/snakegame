extends Node2D

var speed = 100.0
var timer : float = 0.5

func _process(delta: float) -> void:
	position += Vector2.DOWN.rotated(rotation) * speed * delta
	modulate.a *= 0.9
	timer -= delta
	if timer <= 0.0: queue_free()
