extends StaticBody2D

@onready var animation_player = $AnimationPlayer
@onready var entrance = $Entrance
@onready var tile_map = $".."
@onready var player = $"../player"

var roof_layer : int = 6
var inside : bool = false

func _on_area_2d_area_entered(_area):
	animation_player.play("open_door")
	entrance.set_deferred("disabled", true)

func _on_area_2d_area_exited(_area):
	animation_player.play("close_door")
	entrance.set_deferred("disabled", false)

func _on_leave_area_entered(_area):
	if not inside:
		inside = true
		tile_map.set_layer_enabled(roof_layer, false)


func _on_leave_area_exited(_area):
	if player.direction.y > 0:
		inside = false
		tile_map.set_layer_enabled(roof_layer, true)
