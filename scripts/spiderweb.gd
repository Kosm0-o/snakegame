extends Node2D

func _process(delta: float) -> void:
	$shape.scale = lerp($shape.scale, Vector2.ONE, 7 * delta)
