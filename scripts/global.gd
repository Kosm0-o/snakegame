extends Node

var mapsize : Vector2i = Vector2i(58, 33)
const tilesize : int = 20
const offset : Vector2i = Vector2i(tilesize / 2, tilesize / 2)
var effectmodulate : CanvasModulate = null
var player : Player
var currentboss 

#spider boss
var webcount : int = 0
var eggcount : int = 0
var puddlecount : int = 0
var sendingweb : bool = false

func _process(delta: float) -> void:
	if is_instance_valid(effectmodulate):
		effectmodulate.color = lerp(effectmodulate.color, Color.WHITE, 3 * delta)

func endscreen(win : bool):
	var endscreen = load("res://scenes/endscreen.tscn").instantiate()
	get_tree().current_scene.add_child(endscreen)
	endscreen.get_node("Control").modulate.a = 0
	endscreen.get_node("Control").get_node("Label").text = "YOU WIN!" if win else "YOU LOSE!"
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(endscreen.get_node("Control"), "modulate:a", 1.0, 0.8)
