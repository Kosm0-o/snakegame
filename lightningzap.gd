extends Node2D

var length : float = 0.0
var div : float = 18.0
var frames : int = 3
var y_range : float = 15.0
var dealt : bool = false
var dmg : int = 1
var playerpos : Vector2

func _ready() -> void:
	playerpos = global.player.snake.front() * global.tilesize + global.offset
	length = sqrt(playerpos.distance_squared_to(global.currentboss.global_position)) 
	for i in range(int(length / div)):
		for line in $lines.get_children():
			line.add_point(Vector2(i * div, randf_range(-y_range, y_range)))
	$glow.add_point(Vector2(length, 0))

func _process(delta: float) -> void:
	playerpos = global.player.snake.front() * global.tilesize + global.offset
	rotation = playerpos.direction_to(global.currentboss.global_position).angle()
	length = sqrt(playerpos.distance_squared_to(global.currentboss.global_position)) 
	$glow.points[-1].x = length
	global_position = playerpos
	$RayCast2D.target_position.x = length
	frames -= 1
	if frames <= 0:
		frames = 3
		for line in $lines.get_children():
			line.clear_points()
		for i in range(int(length / div)):
			for line in $lines.get_children():
				line.add_point(Vector2(i * div, randf_range(-y_range, y_range)))
	
	if $RayCast2D.is_colliding():
		var hit = $RayCast2D.get_collider()
		if hit is Area2D and not dealt:
			dealt = true
			for i in range(3):
				hit.get_parent().damage(dmg, Color("#00dbff") + Color(1.5,1.5,1.5,1.5))
				hit.get_parent().stun(1.0)
				for j in range(24):
					await get_tree().process_frame
