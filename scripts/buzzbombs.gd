extends Node2D


func _on_hitbox_area_entered(area: Area2D) -> void:
	global.player._remove_segment()
	queue_free()
