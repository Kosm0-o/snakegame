extends Node2D

var flipped : bool = false
var d : float = 5.0
var to_delete : Array = []
var damaged : bool = false

func _ready() -> void:
	if flipped:
		scale.x = -1
		position.x = 1152
	$AnimationPlayer.play("spread")
	await $AnimationPlayer.animation_finished
	queue_free()

func _process(delta: float) -> void:
	$AnimationPlayer.speed_scale *= 0.995


func _on_area_2d_area_entered(area: Area2D) -> void:
	if damaged: return
	damaged = true
	var amt = global.player.snake.size()
	for i in range(ceil(amt/2)):
		global.player._remove_segment()
		await get_tree().process_frame
		await get_tree().process_frame
