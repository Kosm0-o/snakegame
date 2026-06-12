extends Node

var mapsize : Vector2i = Vector2i(58, 33)
const tilesize : int = 20
const offset : Vector2i = Vector2i(tilesize / 2, tilesize / 2)
var effectmodulate : CanvasModulate
var player : Player

#spider boss
var webcount : int = 0
var sendingweb : bool = false

func _process(delta: float) -> void:
	effectmodulate.color = lerp(effectmodulate.color, Color.WHITE, 3 * delta)
