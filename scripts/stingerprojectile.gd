extends Node2D

@export var speed : float = 50.0

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += transform.x * speed
	speed *= 0.99


func _on_area_2d_area_entered(area: Area2D) -> void:
	global.player._remove_segment()
	queue_free()
