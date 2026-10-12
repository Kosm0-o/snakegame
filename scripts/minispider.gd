extends Node2D


var dir : Vector2i = Vector2i.RIGHT
var moveframenum : int = randi_range(12, 18)
var frames : int = moveframenum

@onready var legs: Node2D = $shape/main/body/legs
var legcd : int = 1
var legframes : int = 0

var lifetime : float = randf_range(5, 12)
var timer : float = lifetime

var toxic : bool = randf() < 0.1

func _ready() -> void:
	modulate = Color.WHITE if not toxic else Color("#a4ff9d")

func _process(delta: float) -> void:
	for type in legs.get_children():
		for leg in type.get_children():
			var goal = 0 if "forward" in leg.name else PI
			leg.rotation = lerpf(leg.rotation, goal, 7 * delta)
	var d = global.player.snake.front() - Vector2i(global_position / global.tilesize)

	if abs(d.x) > abs(d.y):
		dir = Vector2i(sign(d.x), 0)
	else:
		dir = Vector2i(0, sign(d.y))
	
	frames -= 1
	if frames <= 0:
		global_position += Vector2(dir) * global.tilesize
		rotation = Vector2(dir).angle()
		frames = moveframenum
		if randf() > 0.9 and toxic:
			create_toxic_puddle()
	
	
	legframes -= 1
	if legframes <= 0:
		var type = legs.get_children().pick_random()
		var m = 1 if "back" in type.name else -1
		var leg = type.get_children().pick_random()
		var mm = 1 if "forward" in leg.name else -1
		leg.rotation += (PI / 16) * m * mm
		legframes = legcd
	
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	global.player._remove_segment()
	if toxic:
		await get_tree().process_frame
		global.player._remove_segment()
	global.player.angry()
	global.effectmodulate.color = Color("#c70000") if not toxic else Color("#a4ff9d")
	queue_free()

func create_toxic_puddle():
	global.puddlecount += 1
	var toxicpuddle = preload("res://toxicpuddle.tscn").instantiate()
	toxicpuddle.name = "toxicpuddle" + str(global.puddlecount)
	get_tree().current_scene.add_child(toxicpuddle)
	toxicpuddle.global_position = global_position
