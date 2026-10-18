extends Node2D

var tile_colors : Array = [
	[Color("#280042"), Color("#140023")],
	[Color("#654e00"), Color("#2b1e00")]
	
]
var tiles : Array = []

func _ready() -> void:
	global.effectmodulate = $EffectMod
	randomize()
	spawn_item()
	match global.bosses_beaten:
		0:
			spawn_wasp()
			#spawn_spider()
		1:
			spawn_wasp()
		2:
			spawn_scorpion()
	for x in range(global.mapsize.x - 75, global.mapsize.x + 1):
		for y in range(global.mapsize.y - 50, global.mapsize.y + 1):
			tiles.append(Vector2i(x, y))

func _process(delta: float) -> void:
	if tiles.is_empty(): return
	for i in range(100):
		if tiles.is_empty(): break
		spawn_next_tile()
		

func spawn_next_tile():
	$tilesound.play()
	var pos = tiles.pop_front()
	var rect = ColorRect.new()
	if pos.x % 2 == 0:
		rect.color = tile_colors[global.bosses_beaten][0] if pos.y % 2 == 0 else tile_colors[global.bosses_beaten][1]
	else:
		rect.color = tile_colors[global.bosses_beaten][0] if pos.y % 2 == 1 else tile_colors[global.bosses_beaten][1]
	rect.size = Vector2i.ONE * global.tilesize
	rect.position = pos * global.tilesize
	$background.add_child(rect)
	

func spawn_item():
	var item = preload("res://scenes/item.tscn").instantiate()
	call_deferred("add_child", item)
	item.position = Vector2i(randi_range(1, global.mapsize.x - 1), randi_range(1, global.mapsize.y - 1)) * global.tilesize + global.offset

func nextboss():
	global.bosses_beaten += 1
	get_tree().reload_current_scene()

func spawn_spider():
	var spider = preload("res://scenes/bosses/spiderboss.tscn").instantiate()
	add_child(spider)
	spider.global_position = Vector2(576.0, 26.0)

func spawn_wasp():
	var wasp = preload("res://scenes/bosses/waspboss.tscn").instantiate()
	wasp.markers = $markers
	add_child(wasp)
	

func spawn_scorpion():
	pass

func _on_exitdetector_area_entered(area: Area2D) -> void:
	area.get_parent().get_parent().get_parent()._die(area)
