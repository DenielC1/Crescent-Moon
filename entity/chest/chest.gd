extends StaticBody2D

@onready var animation_player = $AnimationPlayer

var in_range = false
var opened = false
var chest_data : InventoryData

func _ready():
	pass
func _input(event):
	if event.is_action_pressed("interact") and in_range and not opened:
		opened = true
		animation_player.play("open")
	elif  in_range and event.is_action_pressed("interact") and opened:
		opened = false
		animation_player.play("close")

func _on_player_detection_area_entered(_area):
	in_range = true

func _on_player_detection_area_exited(_area):
	in_range = false
	opened = false
	animation_player.play("close")
