extends Node2D

func _ready() -> void:
	global.effectmodulate = $EffectMod
	randomize()
	spawn_item()
	for x in range(global.mapsize.x - 75, global.mapsize.x + 1):
		for y in range(global.mapsize.y - 50, global.mapsize.y + 1):
			var rect = ColorRect.new()
			if x % 2 == 0:
				rect.color = Color("#280042") if y % 2 == 0 else Color("#140023")
			else:
				rect.color = Color("#280042") if y % 2 == 1 else Color("#140023")
			rect.size = Vector2i.ONE * global.tilesize
			rect.global_position = Vector2i(x,y) * global.tilesize
			$background.add_child(rect)

func spawn_item():
	var item = preload("res://item.tscn").instantiate()
	call_deferred("add_child", item)
	item.position = Vector2i(randi_range(1, global.mapsize.x), randi_range(1, global.mapsize.y)) * global.tilesize + global.offset


func _on_exitdetector_area_entered(area: Area2D) -> void:
	area.get_parent().get_parent().get_parent()._die(area)
