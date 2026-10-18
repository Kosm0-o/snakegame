extends Node2D


func _on_hitbox_area_entered(area: Area2D) -> void:
	for i in range(2):
		global.player._remove_segment()
		await get_tree().process_frame
	queue_free()
