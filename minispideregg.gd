extends Node2D

var freq : float = randf_range(1.5,3.0)
var amp : float = randf_range(0.05, 0.25)
var time : float = 0.0
var offset : float = 0.5

func _process(delta: float) -> void:
	time += delta
	var amt = (sin(time * freq) * amp)
	scale.x = 1.0 + amt
	scale.y = 1.0 - amt
	if time >= 5.0:
		spawn_minispider()

func spawn_minispider():
	var minispider = preload("res://minispider.tscn").instantiate()
	get_tree().current_scene.add_child(minispider)
	minispider.rotation_degrees = randi_range(0, 3) * 90
	minispider.position = position
	call_deferred("queue_free")
