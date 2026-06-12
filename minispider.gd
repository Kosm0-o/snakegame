extends Node2D

var startpos : Vector2i = Vector2i.ONE * 25

var dir : Vector2i = Vector2i.RIGHT
var moveframenum : int = 15
var frames : int = moveframenum

@onready var legs: Node2D = $shape/main/body/legs
var legcd : int = 3
var legframes : int = 0

func _ready() -> void:
	position = startpos * global.tilesize + global.offset

func _process(delta: float) -> void:
	for leg in legs.get_children():
		leg.rotation = lerpf(leg.rotation, 0, 3 * delta)
	
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
	
	
	legframes -= 1
	if legframes <= 0:
		legs.get_children().pick_random().rotation += PI / 16
		legframes = legcd
