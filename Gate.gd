extends StaticBody2D

@onready var animation_player = $AnimationPlayer
@onready var entrance = $Entrance

func _on_area_2d_area_entered(_area):
	animation_player.play("open_gate")
	entrance.set_deferred("disabled", true)


func _on_area_2d_area_exited(_area):
	animation_player.play("close_gate")
	entrance.set_deferred("disabled", false)
