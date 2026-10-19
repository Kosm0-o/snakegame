extends Node2D

@export var pseudoplayer : Node2D
var time : float = 0.0
var notstarttweened : bool = true

var beat : int = 0
const bpm : float = 104.0

var transtiles : Array = []

var zas : Array = []
var xas : Array = []
@onready var zlbl: Label = $ui/beat/abiltiespanel/z/Label
@onready var xlbl: Label = $ui/beat/abiltiespanel/x/Label
var zdx : int = 0
var xdx : int = 0



func _ready() -> void:
	for c in find_children("*", "Control", true, false):
		c.focus_mode = Control.FOCUS_NONE
	zas = global.Z_A.keys()
	xas = global.X_A.keys()
	zlbl.text = zas.front()
	xlbl.text = xas.front()
	$ui/beat/abiltiespanel/z/up.pressed.connect(change_z_ability)
	$ui/beat/abiltiespanel/z/down.pressed.connect(change_z_ability.bind(-1))
	$ui/beat/abiltiespanel/x/up.pressed.connect(change_x_ability)
	$ui/beat/abiltiespanel/x/down.pressed.connect(change_x_ability.bind(-1))
	for x in range(global.mapsize.x - 75, global.mapsize.x + 1):
		for y in range(global.mapsize.y - 50, global.mapsize.y + 1):
				var rect = ColorRect.new()
				if x % 2 == 0:
					rect.color = Color("#6B5A52") if y % 2 == 0 else Color("#4B3D37")
				else:
					rect.color = Color("#6B5A52") if y % 2 == 1 else Color("#4B3D37")
				rect.size = Vector2i.ONE * global.tilesize
				rect.position = Vector2i(x, y) * global.tilesize
				$background.add_child(rect)
	for area in $teleportareas.get_children():
		var b : bool = true
		var p : int = 0
		match area.name:
			"top":
				b = false
				p = 33
			"bottom":
				b = false
				p = -33
			"left":
				b = true
				p = 58
			"right":
				b = true
				p = -58
		area.area_entered.connect(_set_head.bind(b, p))
	

func _process(delta: float) -> void:
	if pseudoplayer.start and notstarttweened:
		starttexttween()
	time += delta
	$ui/beat/presstostart.modulate.a = sin(3 * time) * 0.15 + 0.7
	
	$ui/beat.position = lerp($ui/beat.position, Vector2.ZERO, 3 * delta)
	
	var curbeat = floor($bgmusic.get_playback_position() / (60.0 / bpm))
	
	if curbeat > beat:
		beat = curbeat
		$ui/beat.position += Vector2(randf_range(-10, 10), randf_range(-10, 10))
	
	if transtiles.is_empty(): return
	for i in range(25):
		if transtiles.is_empty(): break
		spawn_next_tile()

func spawn_next_tile():
	$ui/transition/tilesound.play()
	var pos = transtiles.pop_front()
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.size = Vector2i.ONE * global.tilesize
	rect.position = pos * global.tilesize
	$ui/transition.add_child(rect)

func starttexttween():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($ui/beat/presstostart, "position", Vector2(296.5, 639.0), 0.6)
	await tween.finished

func _set_head(area: Area2D, x : bool, pos : int):
	if x:
		pseudoplayer.snake[0] += Vector2i(pos, 0)
	else:
		pseudoplayer.snake[0] += Vector2i(0, pos)

func abilities_tween(out : bool):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var pos = Vector2(1169, 120) if out else Vector2(666, 120)
	tween.tween_property($ui/beat/abiltiespanel, "position", pos, 0.4)
	await tween.finished
#	get_tree().paused = not out


func _on_play_area_entered(area: Area2D) -> void:
	$buttonareas/quit.monitoring = false
	for x in range(global.mapsize.x - 75, global.mapsize.x + 1):
		for y in range(global.mapsize.y - 50, global.mapsize.y + 1):
			transtiles.append(Vector2i(x, y))
	while not transtiles.is_empty():
		await get_tree().process_frame
	get_tree().call_deferred("change_scene_to_file","res://scenes/game.tscn")

func _on_quit_area_entered(area: Area2D) -> void:
	get_tree().quit()

func _on_abilities_area_entered(area: Area2D) -> void:
	abilities_tween(false)

func _on_exit_pressed() -> void:
	abilities_tween(true)


func change_z_ability(delta : int = 1) -> void:
	if (zdx == 0 and delta == 1) or (zdx == zas.size() - 1 and delta == -1):
		return
	zdx -= delta
	zlbl.text = zas[zdx]
	global.zability = zdx as global.Z_A
	
func change_x_ability(delta : int = 1) -> void:
	if (xdx == 0 and delta == 1) or (xdx == xas.size() - 1 and delta == -1):
		return
	xdx -= delta
	xlbl.text = xas[xdx]
	global.xability = xdx as global.X_A
