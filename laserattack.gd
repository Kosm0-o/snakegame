extends Node2D

@onready var laser: Line2D = $laser
@onready var detector: RayCast2D = $detector
@export var maxx : float = 1152.0
@export var frames : float = 20.0

func _ready() -> void:
	laser.points[-1].x = 0
	detector.target_position.x = 0

func _process(delta: float) -> void:
	laser.points[-1].x = min(laser.points[-1].x * 1.85 + 1, 1152.0)
	detector.target_position.x = min(detector.target_position.x * 1.85 + 1, 1152.0)
	laser.width = min(laser.width * 1.25, 15.0)
	
	
	if detector.is_colliding():
		var hit = detector.get_collider()
		if hit is Area2D:
			global.player._remove_segment()
			global.player.angry()
			detector.add_exception(hit)
	
	frames -= 1
	if frames <= 0:
		queue_free()
