extends Node2D

var attacks : Array = ["dash", "stingerspray", "triplebite", "buzzbomb"]
var start : bool = false

var attacking : bool = false # for bugs/glitches
var stunned : bool = false
var stuntime : float = 0.0

func _ready() -> void:
	randomize()
	global.currentboss = self
	$shape.global_position = $markers/origin.global_position
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($introtext/Label, "modulate:a", 1.0, 1.2)
	tween.tween_property($introtext/Label, "modulate:a", 0.0, 0.5).set_delay(0.6)
	await tween.finished
	get_tree().paused = false
	var tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(self, "modulate:a", 0.7, 0.7)
	$attackplayer.play("ready")
	start = true
	
func _process(delta: float) -> void:
	if stuntime > 0.0:
		stunned = true
		stuntime -= delta
	else:
		stunned = false
	
	if start and not $attackplayer.is_playing() and not attacking and not stunned:
		attacking = true
		var atk = attacks.pick_random()
		dash()#$attackplayer.play(atk)

func dash():
	hide()
	var num = randi_range(0, 3)
	var pos = $markers/dash.get_child(num).global_position
	await get_tree().create_timer(0.1).timeout
	$shape.global_position = pos
	show()
	var rtween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	rtween.tween_property($shape, "rotation_degrees", 90 * num + 180, 0.4)
	await rtween.finished
