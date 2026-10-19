extends Node2D

@export var dmg : int = 1

func _ready() -> void:
	$anim.play("slash")
	await $anim.animation_finished
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	area.get_parent().damage(dmg, Color("#ff170f"))
	queue_free()
